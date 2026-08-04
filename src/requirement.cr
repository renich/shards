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
        when /~>\s*([^\s]+)\d*/
          req = $1
          ver = if idx = req.rindex('.')
                  req[0...idx]
                else
                  req
                end
          Condition.new(Op::Approx, req, ver)
        when /\s*(~>|>=|<=|!=|>|<|=)\s*([^~<>=!\s]+)\s*/
          op_str, req = $1, $2
          op = case op_str
               when "~>" then Op::Approx
               when ">=" then Op::Gte
               when "<=" then Op::Lte
               when ">"  then Op::Gt
               when "<"  then Op::Lt
               when "="  then Op::Eq
               when "!=" then Op::Neq
               else           Op::Eq
               end
          Condition.new(op, req, nil)
        else
          Condition.new(Op::Eq, pattern, nil)
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
