module Shards
  # Represents a build target defined in `shard.yml`.
  #
  # A target defines an executable that can be built by the project.
  # It specifies the name of the executable and its main entry point.
  #
  # ```
  # target = Shards::Target.new("my_app", "src/cli.cr")
  # target.name # => "my_app"
  # target.main # => "src/cli.cr"
  # ```
  class Target
    # The name of the target executable.
    property name : String

    # The main source file path for this target.
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
