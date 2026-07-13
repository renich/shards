module Shards
  # Represents a build target in a `shard.yml` file.
  #
  # A target defines an executable that can be built from the shard.
  # It specifies the name of the executable and the main entry point source file.
  #
  # ```crystal
  # target = Shards::Target.new("my_app", "src/my_app.cr")
  # target.name # => "my_app"
  # target.main # => "src/my_app.cr"
  # ```
  class Target
    # The name of the target executable.
    property name : String

    # The path to the main entry point source file for this target.
    property main : String

    # Parses a `Target` from a YAML pull parser.
    #
    # Raises `YAML::ParseException` if the `main` property is missing.
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

    # Creates a new `Target` with the given *name* and *main* entry point.
    def initialize(@name, @main)
    end
  end
end
