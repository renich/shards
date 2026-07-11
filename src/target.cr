module Shards
  # Represents a build target in a `shard.yml` file.
  #
  # A target describes an executable to be built by Shards, including its
  # name and the path to its main Crystal source file.
  #
  # ```
  # target = Shards::Target.new("my_app", "src/main.cr")
  # target.name # => "my_app"
  # target.main # => "src/main.cr"
  # ```
  class Target
    property name : String
    property main : String

    def self.new(pull : YAML::PullParser) : self
      start_pos = pull.location
      name = pull.read_scalar
      main = nil

      pull.each_in_mapping do
        case pull.read_scalar
        when "main"
          main = pull.read_scalar
        else
          # ignore unknown dependency mapping for future extensions
        end
      end

      unless main
        raise YAML::ParseException.new(%(Missing property "main" for target #{name.inspect}), *start_pos)
      end

      Target.new(name, main)
    end

    def initialize(@name, @main)
    end
  end
end
