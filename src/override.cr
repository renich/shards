require "colorize"
require "./ext/yaml"
require "./config"
require "./dependency"
require "./errors"
require "./target"

module Shards
  class Override
    # Reads and parses an override configuration file.
    #
    # The `path` can be either a direct path to the file (e.g. `shard.override.yml`)
    # or a directory containing a `shard.override.yml` file.
    # If `validate` is true, strict validation is performed (e.g. raising an error on unknown attributes).
    #
    # Raises `Error` if the file does not exist.
    # Raises `ParseError` if the YAML content is invalid.
    #
    # ```
    # override = Shards::Override.from_file("/path/to/project")
    # ```
    def self.from_file(path, validate = false)
      path = File.join(path, OVERRIDE_FILENAME) if File.directory?(path)
      raise Error.new("Missing #{File.basename(path)}") unless File.exists?(path)
      from_yaml(File.read(path), path, validate)
    end

    # Parses an override configuration from a YAML string or IO.
    #
    # The `input` provides the YAML data.
    # The `filename` is used in error messages (default is `OVERRIDE_FILENAME`).
    # If `validate` is true, strict validation is performed (e.g. raising an error on unknown attributes).
    #
    # Raises `ParseError` if the YAML content is invalid or fails validation.
    #
    # ```
    # yaml = "dependencies:\n  sqlite3:\n    github: crystal-lang/crystal-sqlite3\n"
    # override = Shards::Override.from_yaml(yaml)
    # ```
    def self.from_yaml(input, filename = OVERRIDE_FILENAME, validate = false)
      parser = YAML::PullParser.new(input)
      parser.read_stream do
        if parser.kind.stream_end?
          return new([] of Dependency)
        end
        parser.read_document do
          new(parser, validate)
        end
      end
    rescue ex : YAML::ParseException
      raise ParseError.new(ex.message, input, filename, ex.line_number, ex.column_number)
    ensure
      parser.close if parser
    end

    def self.new(pull : YAML::PullParser, validate = false) : self
      dependencies = nil
      pull.each_in_mapping do
        line, column = pull.location

        case key = pull.read_scalar
        when "dependencies"
          check_duplicate(dependencies, "dependencies", line, column)
          dependencies = [] of Dependency
          pull.each_in_mapping do
            dependencies << Dependency.from_yaml(pull)
          end
        else
          if validate
            pull.raise "unknown attribute: #{key}", line, column
          else
            pull.skip
          end
        end
      end
      new(dependencies || [] of Dependency)
    end

    private def self.check_duplicate(argument, name, line, column)
      unless argument.nil?
        raise YAML::ParseException.new("duplicate attribute #{name.inspect}", line, column)
      end
    end

    getter dependencies : Array(Dependency)

    def initialize(@dependencies : Array(Dependency))
    end
  end
end
