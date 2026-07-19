module Shards
  struct VersionReq
    enum Kind
      Any
      Approx
      Operator
    end

    record Condition, kind : Kind, requirement : String, ver : String

    getter patterns : Array(String)
    getter parsed_patterns : Array(Condition)

    def initialize(patterns)
      @patterns = patterns.split(',', remove_empty: true).map &.strip
      @parsed_patterns = @patterns.map do |pattern|
        case pattern
        when "*", ""
          Condition.new(Kind::Any, "", "")
        when /~>\s*([^\s]+)\d*/
          ver = if idx = $1.rindex('.')
                  $1[0...idx]
                else
                  $1
                end
          Condition.new(Kind::Approx, $1, ver)
        when /\s*(~>|>=|<=|!=|>|<|=)\s*([^~<>=!\s]+)\s*/
          Condition.new(Kind::Operator, $1, $2)
        else
          Condition.new(Kind::Operator, "=", pattern)
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
