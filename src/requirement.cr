module Shards
  struct VersionReq
    enum Operator
      ANY
      APPROXIMATE
      GREATER_OR_EQUAL
      LESS_OR_EQUAL
      GREATER
      LESS
      NOT_EQUAL
      EQUAL
    end

    record Pattern, operator : Operator, requirement : String, ver : String? = nil

    getter patterns : Array(String)
    protected getter parsed_patterns : Array(Pattern)

    def initialize(patterns)
      @patterns = patterns.split(',', remove_empty: true).map &.strip
      @parsed_patterns = @patterns.map do |pattern|
        case pattern
        when "*", ""
          Pattern.new(Operator::ANY, "")
        when /~>\s*([^\s]+)\d*/
          ver = if idx = $1.rindex('.')
                  $1[0...idx]
                else
                  $1
                end
          Pattern.new(Operator::APPROXIMATE, $1, ver)
        when /\s*(~>|>=|<=|!=|>|<|=)\s*([^~<>=!\s]+)\s*/
          op = case $1
               when ">=" then Operator::GREATER_OR_EQUAL
               when "<=" then Operator::LESS_OR_EQUAL
               when ">"  then Operator::GREATER
               when "<"  then Operator::LESS
               when "!=" then Operator::NOT_EQUAL
               else           Operator::EQUAL
               end
          Pattern.new(op, $2)
        else
          Pattern.new(Operator::EQUAL, pattern)
        end
      end
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
