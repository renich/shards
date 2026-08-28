module Shards
  struct VersionReq
    enum Op
      Any
      Approx
      Gte
      Lte
      Gt
      Lt
      Eq
      Neq
    end

    record Condition, op : Op, req : String, ver : String?

    getter patterns : Array(String)
    getter conditions : Array(Condition)

    def initialize(patterns)
      @patterns = patterns.split(',', remove_empty: true).map &.strip
      @conditions = @patterns.map do |pattern|
        case pattern
        when "*", ""
          Condition.new(Op::Any, "", nil)
        else
          if op_and_pos = parse_operator(pattern)
            op, pos = op_and_pos

            reader = Char::Reader.new(pattern, pos)
            while reader.has_next? && reader.current_char.ascii_whitespace?
              reader.next_char
            end

            req_start = reader.pos
            while reader.has_next? && !reader.current_char.ascii_whitespace?
              reader.next_char
            end
            req_end = reader.pos
            req = pattern.byte_slice(req_start, req_end - req_start)

            if req.empty?
              Condition.new(Op::Eq, pattern, nil)
            elsif op == Op::Approx
              ver = if idx = req.rindex('.')
                      req.byte_slice(0, idx)
                    else
                      req
                    end
              Condition.new(Op::Approx, req, ver)
            else
              Condition.new(op, req, nil)
            end
          else
            Condition.new(Op::Eq, pattern, nil)
          end
        end
      end
    end

    private def parse_operator(pattern)
      reader = Char::Reader.new(pattern)
      while reader.has_next? && reader.current_char.ascii_whitespace?
        reader.next_char
      end
      return nil unless reader.has_next?

      c1 = reader.current_char
      if c1 == '~'
        reader.next_char
        if reader.has_next? && reader.current_char == '>'
          reader.next_char
          return {Op::Approx, reader.pos}
        end
      elsif c1 == '>'
        reader.next_char
        if reader.has_next? && reader.current_char == '='
          reader.next_char
          return {Op::Gte, reader.pos}
        else
          return {Op::Gt, reader.pos}
        end
      elsif c1 == '<'
        reader.next_char
        if reader.has_next? && reader.current_char == '='
          reader.next_char
          return {Op::Lte, reader.pos}
        else
          return {Op::Lt, reader.pos}
        end
      elsif c1 == '!'
        reader.next_char
        if reader.has_next? && reader.current_char == '='
          reader.next_char
          return {Op::Neq, reader.pos}
        end
      elsif c1 == '='
        reader.next_char
        return {Op::Eq, reader.pos}
      end

      nil
    end

    def prerelease?
      patterns.any? do |pattern|
        Versions.prerelease? pattern
      end
    end

    def to_s(io)
      patterns.join(io, ", ")
    end

    def to_yaml(yaml)
      yaml.scalar "version"
      yaml.scalar to_s
    end
  end

  struct Version
    getter value : String

    def initialize(@value)
    end

    def has_metadata?
      Versions.has_metadata? @value
    end

    def prerelease?
      Versions.prerelease? @value
    end

    def to_s(io)
      io << value
    end

    def to_yaml(yaml)
      yaml.scalar "version"
      yaml.scalar value
    end
  end

  abstract struct Ref
  end

  module Any
    extend self

    def to_s(io)
      io << "*"
    end

    def to_yaml(yaml)
    end
  end

  alias Requirement = VersionReq | Version | Ref | Any
end
