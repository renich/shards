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
        if pattern == "*" || pattern.empty?
          Condition.new(Op::Any, "", nil)
        else
          if pattern.starts_with?("~>")
            req = pattern.byte_slice(2).strip
            ver = if idx = req.rindex('.')
                    req[0...idx]
                  else
                    req
                  end
            Condition.new(Op::Approx, req, ver)
          elsif pattern.starts_with?(">=")
            req = pattern.byte_slice(2).strip
            Condition.new(Op::Gte, req, nil)
          elsif pattern.starts_with?("<=")
            req = pattern.byte_slice(2).strip
            Condition.new(Op::Lte, req, nil)
          elsif pattern.starts_with?("!=")
            req = pattern.byte_slice(2).strip
            Condition.new(Op::Neq, req, nil)
          elsif pattern.starts_with?(">")
            req = pattern.byte_slice(1).strip
            Condition.new(Op::Gt, req, nil)
          elsif pattern.starts_with?("<")
            req = pattern.byte_slice(1).strip
            Condition.new(Op::Lt, req, nil)
          elsif pattern.starts_with?("=")
            req = pattern.byte_slice(1).strip
            Condition.new(Op::Eq, req, nil)
          else
            Condition.new(Op::Eq, pattern, nil)
          end
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
