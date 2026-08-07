module Shards
  module Script
    class Error < Error
    end

    # Executes a shell command within the specified directory.
    #
    # Changes the current working directory to `path`, then executes `command` in a shell.
    # The output and error streams are captured.
    #
    # Raises `Shards::Script::Error` if the command fails (i.e., its exit status is not successful).
    #
    # ```
    # Shards::Script.run("/path/to/project", "make", "postinstall", "my_dependency")
    # ```
    def self.run(path : String, command : String, script_name : String, dependency_name : String)
      Dir.cd(path) do
        output = IO::Memory.new
        status = Process.run(command, shell: true, output: output, error: output)
        raise Error.new("Failed #{script_name} of #{dependency_name} on #{command}:\n#{output.to_s.rstrip}") unless status.success?
      end
    end
  end
end
