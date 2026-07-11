module Shards
  enum PatternKind
    Any
    Approximate
    Operator
  end

  struct ParsedPattern
    getter kind : PatternKind
    getter op : String
    getter req : String

    def initialize(@kind : PatternKind, @op : String, @req : String)
    end
  end

  struct VersionReq
    getter patterns : Array(String)
    getter parsed_patterns : Array(ParsedPattern)

    def initialize(patterns)
      @patterns = patterns.split(',', remove_empty: true).map &.strip
      @parsed_patterns = @patterns.map do |pattern|
        case pattern
        when "*", ""
          ParsedPattern.new(PatternKind::Any, "", "")
        when /~>\s*([^\s]+)\d*/
          req = $1
          ver = if idx = req.rindex('.')
                  req[0...idx]
                else
                  req
                end
          ParsedPattern.new(PatternKind::Approximate, req, ver)
        when /\s*(~>|>=|<=|!=|>|<|=)\s*([^~<>=!\s]+)\s*/
          ParsedPattern.new(PatternKind::Operator, $1, $2)
        else
          ParsedPattern.new(PatternKind::Operator, "=", pattern)
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
