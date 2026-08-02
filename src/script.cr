module Shards
  module Script
    class Error < Error
    end

    # Executes a shell command within a specified directory.
    #
    # Changes the current working directory to `path`, then runs `command` using the shell.
    # If the command fails (returns a non-zero exit status), it raises a `Shards::Script::Error`
    # containing the `script_name`, `dependency_name`, the executed command, and the command's output.
    #
    # Example:
    # ```
    # Shards::Script.run("/path/to/shard", "make install", "postinstall", "my_dependency")
    # ```
    #
    # Raises:
    # * `Shards::Script::Error`: if the `command` exits with a non-zero status code.
    def self.run(path, command, script_name, dependency_name)
      Dir.cd(path) do
        output = IO::Memory.new
        status = Process.run(command, shell: true, output: output, error: output)
        raise Error.new("Failed #{script_name} of #{dependency_name} on #{command}:\n#{output.to_s.rstrip}") unless status.success?
      end
    end
  end
end
