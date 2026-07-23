module Shards
  module Script
    class Error < Error
    end

    # Executes a shell command within a specified directory.
    #
    # This method is primarily used for running custom `postinstall` scripts defined in a `shard.yml`.
    # It evaluates the shell string and captures its output. If the process does not terminate successfully,
    # it raises an error containing the output of the process.
    #
    # * *path*: The directory path where the command should be executed.
    # * *command*: The shell command string to execute.
    # * *script_name*: The name of the script being run (e.g., `"postinstall"`).
    # * *dependency_name*: The name of the shard or dependency running the script.
    #
    # Raises `Shards::Script::Error` if the execution of the command fails (non-zero exit status).
    #
    # ```
    # Shards::Script.run("/path/to/shard", "make install", "postinstall", "my_shard")
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
