module Shards
  # Represents a version requirement parsed from a `shard.yml` dependency.
  #
  # A requirement is a comma-separated list of patterns.
  # Example patterns are `>= 1.0.0`, `~> 1.2`, `< 2.0.0`.
  #
  # ```crystal
  # req = Shards::VersionReq.new(">= 1.2.3, < 2.0.0")
  # req.patterns # => [">= 1.2.3", "< 2.0.0"]
  # req.prerelease? # => false
  # ```
  struct VersionReq
    getter patterns : Array(String)

    # Initializes a new `VersionReq` with the given requirement string.
    #
    # The `patterns` argument is a comma-separated string containing one or more version conditions.
    # Empty parts are removed, and whitespace is stripped from each extracted pattern.
    #
    # ```crystal
    # req = Shards::VersionReq.new("  ~> 0.2.0 ,  < 0.3.0 ")
    # req.patterns # => ["~> 0.2.0", "< 0.3.0"]
    # ```
    def initialize(patterns)
      @patterns = patterns.split(',', remove_empty: true).map &.strip
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
