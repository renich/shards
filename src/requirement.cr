module Shards
  struct VersionReq
    enum Op
      Any
      Approximate
      GreaterOrEqual
      LessOrEqual
      Greater
      Less
      NotEqual
      Equal
    end

    record Condition, op : Op, val : String, prefix : String?

    getter patterns : Array(String)
    getter conditions : Array(Condition)

    def initialize(patterns)
      @patterns = patterns.split(',', remove_empty: true).map &.strip
      @conditions = @patterns.map { |p| VersionReq.parse_condition(p) }
    end

    def self.parse_condition(pattern : String) : Condition
      case pattern
      when "*", ""
        Condition.new(Op::Any, "", nil)
      when /~>\s*([^\s]+)\d*/
        val = $1
        prefix = if idx = val.rindex('.')
                   val[0...idx]
                 else
                   val
                 end
        Condition.new(Op::Approximate, val, prefix)
      when /\s*(~>|>=|<=|!=|>|<|=)\s*([^~<>=!\s]+)\s*/
        op = case $1
             when ">=" then Op::GreaterOrEqual
             when "<=" then Op::LessOrEqual
             when ">"  then Op::Greater
             when "<"  then Op::Less
             when "!=" then Op::NotEqual
             when "="  then Op::Equal
             else           Op::Equal
             end
        Condition.new(op, $2, nil)
      else
        Condition.new(Op::Equal, pattern, nil)
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
