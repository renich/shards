module Shards
  # Represents an executable target defined in a `shard.yml` file.
  #
  # A target typically represents a standalone executable that a shard can build or run.
  # It specifies a name for the executable and the path to its main source file.
  #
  # ```
  # target = Shards::Target.new("my_app", "src/my_app.cr")
  # target.name # => "my_app"
  # target.main # => "src/my_app.cr"
  # ```
  class Target
    # The name of the target executable.
    property name : String

    # The file path to the main source file for this target.
    property main : String

    # Parses a `Target` from a YAML definition using a `YAML::PullParser`.
    #
    # The YAML mapping must contain a `main` property specifying the path
    # to the entry point file. If the `main` property is missing, a
    # `YAML::ParseException` is raised.
    #
    # ```
    # require "yaml"
    #
    # yaml = %(
    #   my_target:
    #     main: src/my_target.cr
    # )
    #
    # pull = YAML::PullParser.new(yaml)
    # pull.read_stream do
    #   pull.read_document do
    #     pull.read_mapping do
    #       target = Shards::Target.new(pull)
    #       target.name # => "my_target"
    #       target.main # => "src/my_target.cr"
    #     end
    #   end
    # end
    # ```
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

    # Creates a new `Target` with the given *name* and *main* source file path.
    def initialize(@name, @main)
    end
  end
end
