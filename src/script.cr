module Shards
  module Script
    class Error < Error
    end

    # Executes a script command within a given directory.
    #
    # This is typically used to run lifecycle scripts defined in `shard.yml`
    # (e.g., `postinstall`).
    #
    # Parameters:
    # - `path` (String): The directory path where the command should be executed.
    # - `command` (String): The shell command to execute.
    # - `script_name` (String): The name of the script being run (e.g., "postinstall"), used in error messages.
    # - `dependency_name` (String): The name of the dependency the script belongs to, used in error messages.
    #
    # Raises:
    # - `Shards::Script::Error` if the command execution fails.
    #
    # Example:
    # ```crystal
    # Shards::Script.run("/path/to/dep", "make", "postinstall", "my_dep")
    # ```
    def self.run(path, command, script_name, dependency_name)
      Dir.cd(path) do
        output = IO::Memory.new
        status = Process.run(command, shell: true, output: output, error: output)
        raise Error.new("Failed #{script_name} of #{dependency_name} on #{command}:\n#{output.to_s.rstrip}") unless status.success?
      end
    end
  end
end
