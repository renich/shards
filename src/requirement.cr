module Shards
  struct VersionReq
    alias Condition = Tuple(String, String, String?)

    getter patterns : Array(String)
    getter parsed_patterns : Array(Condition)

    def initialize(patterns)
      @patterns = patterns.split(',', remove_empty: true).map &.strip
      @parsed_patterns = @patterns.map { |pattern| Versions.parse_single_pattern(pattern) }
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
