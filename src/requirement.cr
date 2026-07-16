module Shards
  struct VersionReq
    enum Operator
      Any
      Approximate
      GreaterThanOrEqualTo
      LessThanOrEqualTo
      GreaterThan
      LessThan
      NotEqual
      Equal
    end

    struct Condition
      getter operator : Operator
      getter requirement : String
      getter ver : String

      def initialize(@operator, @requirement, @ver = "")
      end
    end

    getter patterns : Array(String)
    getter conditions : Array(Condition)

    def initialize(patterns)
      @patterns = patterns.split(',', remove_empty: true).map &.strip
      @conditions = @patterns.map do |pattern|
        case pattern
        when "*", ""
          Condition.new(Operator::Any, "")
        when /~>\s*([^\s]+)\d*/
          req = $1
          ver = if idx = req.rindex('.')
                  req[0...idx]
                else
                  req
                end
          Condition.new(Operator::Approximate, req, ver)
        when /\s*(~>|>=|<=|!=|>|<|=)\s*([^~<>=!\s]+)\s*/
          op_str, req = $1, $2
          op = case op_str
               when ">=" then Operator::GreaterThanOrEqualTo
               when "<=" then Operator::LessThanOrEqualTo
               when ">"  then Operator::GreaterThan
               when "<"  then Operator::LessThan
               when "!=" then Operator::NotEqual
               else           Operator::Equal
               end
          Condition.new(op, req)
        else
          Condition.new(Operator::Equal, pattern)
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
