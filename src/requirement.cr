module Shards
  struct VersionReq
    enum MatchKind
      Any
      Approx
      Op
    end

    alias ParsedPattern = {MatchKind, String, String}

    getter patterns : Array(String)
    getter parsed_patterns : Array(ParsedPattern)

    def initialize(patterns)
      @patterns = patterns.split(',', remove_empty: true).map &.strip
      @parsed_patterns = @patterns.map do |pattern|
        self.class.parse_pattern(pattern)
      end
    end

    protected def self.parse_pattern(pattern : String) : ParsedPattern
      case pattern
      when "*", ""
        {MatchKind::Any, "", ""}
      when /~>\s*([^\s]+)\d*/
        ver = if idx = $1.rindex('.')
                $1[0...idx]
              else
                $1
              end
        {MatchKind::Approx, $1, ver}
      when /\s*(~>|>=|<=|!=|>|<|=)\s*([^~<>=!\s]+)\s*/
        {MatchKind::Op, $1, $2}
      else
        {MatchKind::Op, "=", pattern}
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
