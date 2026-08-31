module Shards
  module Versions
    # :nodoc:
    struct Segment
      protected getter! segment : String

      def initialize(@str : String)
        if index = @str.index('+')
          @str = @str[0...index]
        end
      end

      def next
        if (match = next_non_alphanumeric(@str))
          byte_index, char_bytesize = match
          @segment = @str.byte_slice(0, byte_index)
          @str = @str.byte_slice(byte_index + char_bytesize)
        else
          @segment = @str
          @str = ""
        end
        segment
      end

      private def next_non_alphanumeric(str)
        byte_index = 0
        str.each_char do |c|
          return {byte_index, c.bytesize} if !c.ascii_alphanumeric?
          byte_index += c.bytesize
        end
        nil
      end

      def empty?
        segment.empty?
      end

      def to_i?
        segment.to_i?(whitespace: false)
      end

      def <=>(b : self)
        natural_sort(segment, b.segment)
      end

      # Original natural sorting algorithm from:
      # https://github.com/sourcefrog/natsort/blob/master/natcmp.rb
      # Copyright (C) 2003 by Alan Davies <cs96and_AT_yahoo_DOT_co_DOT_uk>.
      private def natural_sort(a, b)
        if (a_num = a.to_i?(whitespace: false)) && (b_num = b.to_i?(whitespace: false))
          return a_num <=> b_num
        end

        loop do
          return 0 if a.empty? && b.empty?

          a_chars, a_digits, a = split_chars_digits(a)
          b_chars, b_digits, b = split_chars_digits(b)

          ret = a_chars <=> b_chars
          return ret unless ret == 0

          a_num = a_digits.to_i?(whitespace: false)
          b_num = b_digits.to_i?(whitespace: false)

          if a_num && b_num
            ret = a_num.to_i <=> b_num.to_i
            return ret unless ret == 0
          else
            ret = a_digits <=> b_digits
            return ret unless ret == 0
          end
        end
      end

      private def split_chars_digits(str)
        chars_end_byte = 0
        str.each_char do |c|
          break if c.ascii_number?
          chars_end_byte += c.bytesize
        end

        digits_end_byte = chars_end_byte
        str.byte_slice(chars_end_byte).each_char do |c|
          break unless c.ascii_number?
          digits_end_byte += c.bytesize
        end

        {
          str.byte_slice(0, chars_end_byte),
          str.byte_slice(chars_end_byte, digits_end_byte - chars_end_byte),
          str.byte_slice(digits_end_byte),
        }
      end

      def only_zeroes?(&)
        return if empty?
        yield unless to_i? == 0

        loop do
          self.next

          return if empty?
          yield unless to_i? == 0
        end
      end

      def prerelease?
        segment.each_char.any?(&.ascii_letter?)
      end

      def inspect(io)
        @segment.inspect(io)
      end
    end

    # Sorts an array of versions according to semantic and natural versioning rules.
    #
    # ```
    # versions = ["1.0.0-alpha", "0.20.1", "1.0.0", "1.0.0-rc2"]
    # Shards::Versions.sort(versions)
    # ```
    def self.sort(versions)
      versions.sort { |a, b| compare(a, b) }
    end

    def self.compare(a : Version, b : Version)
      compare(a.value, b.value)
    end

    # Compares two semantic version strings.
    #
    # Follows standard comparison semantics:
    # - Returns `1` if `a > b` (i.e., `a` is newer than `b`).
    # - Returns `0` if `a == b`.
    # - Returns `-1` if `a < b`.
    #
    # ```
    # Shards::Versions.compare("1.0.1", "1.0.0")  # => 1
    # Shards::Versions.compare("1.0.0", "1.0.0")  # => 0
    # Shards::Versions.compare("0.20.1", "1.0.0") # => -1
    # ```
    def self.compare(a : String, b : String)
      if a == b
        return 0
      end

      a_segment = Segment.new(a)
      b_segment = Segment.new(b)

      loop do
        # extract next segment from version number ("1.0.2" => "1" then "0" then "2"):
        a_segment.next
        b_segment.next

        # accept unbalanced version numbers ("1.0" == "1.0.0.0", "1.0" < "1.0.1")
        if a_segment.empty?
          b_segment.only_zeroes? { return b_segment.prerelease? ? -1 : 1 }
          return 0
        end

        # accept unbalanced version numbers ("1.0.0.0" == "1.0", "1.0.1" > "1.0")
        if b_segment.empty?
          a_segment.only_zeroes? { return a_segment.prerelease? ? 1 : -1 }
          return 0
        end

        # try to convert segments to numbers:
        a_num = a_segment.to_i?
        b_num = b_segment.to_i?

        ret =
          if a_num && b_num
            # compare numbers (for natural 1, 2, ..., 10, 11 ordering):
            b_num <=> a_num
          elsif a_num
            # b is preliminary version:
            a_segment.only_zeroes? do
              return b_segment <=> a_segment if a_segment.prerelease?
              return -1
            end
            return -1
          elsif b_num
            # a is preliminary version:
            b_segment.only_zeroes? do
              return b_segment <=> a_segment if b_segment.prerelease?
              return 1
            end
            return 1
          else
            # compare strings:
            b_segment <=> a_segment
          end

        # if different return the result (older or newer), otherwise continue
        # to the next segment:
        return ret unless ret == 0
      end
    end

    def self.prerelease?(str : String)
      str.each_char do |char|
        return true if char.ascii_letter?
        break if char == '+'
      end
      false
    end

    def self.has_metadata?(str : String)
      str.includes? '+'
    end

    protected def self.without_prereleases(versions : Array(Version))
      versions.reject { |v| prerelease?(v.value) }
    end

    def self.resolve(versions : Array(Version), requirement : VersionReq)
      versions.select { |version| matches?(version, requirement) }
    end

    def self.matches?(version : Version, requirement : VersionReq)
      requirement.conditions.all? do |condition|
        matches_condition?(version, condition)
      end
    end

    private def self.matches_condition?(version : Version, condition : VersionReq::Condition)
      case condition.op
      when VersionReq::Op::Any
        true
      when VersionReq::Op::Approx
        matches_approximate?(version.value, condition.req, condition.ver.not_nil!)
      when VersionReq::Op::Gte
        compare(version.value, condition.req) <= 0
      when VersionReq::Op::Lte
        compare(version.value, condition.req) >= 0
      when VersionReq::Op::Gt
        compare(version.value, condition.req) < 0
      when VersionReq::Op::Lt
        compare(version.value, condition.req) > 0
      when VersionReq::Op::Eq
        compare(version.value, condition.req) == 0
      when VersionReq::Op::Neq
        compare(version.value, condition.req) != 0
      else
        false
      end
    end

    private def self.matches_approximate?(version, requirement, ver)
      version.starts_with?(ver) &&
        !version[ver.size]?.try(&.ascii_alphanumeric?) &&
        (compare(version, requirement) <= 0)
    end
  end
end
