require "./lock"

# Manages information about installed shards within a specific directory.
#
# This class tracks which packages are currently installed in the target
# path (typically `lib/`) and provides mechanisms to persist and load this
# information using a `.shards.info` YAML file.
#
# ```
# info = Shards::Info.new("lib")
# info.installed["my_shard"] = package
# info.save
# ```
class Shards::Info
  getter install_path : String
  getter installed = Hash(String, Package).new

  # Initializes a new `Info` instance for the given *install_path*.
  #
  # By default, it uses `Shards.install_path`. Upon initialization,
  # it automatically loads the current state by calling `#reload`.
  def initialize(@install_path = Shards.install_path)
    reload
  end

  # Reloads the installed packages information from the `.shards.info` file.
  #
  # If the file exists, it populates `#installed` with the parsed packages.
  # Otherwise, it clears the currently tracked packages.
  def reload
    path = info_path
    if File.exists?(path)
      @installed = Lock.from_file(path).shards.index_by &.name
    else
      @installed.clear
    end
  end

  # Saves the current `#installed` state to the `.shards.info` file.
  #
  # Creates the `#install_path` directory if it does not exist. It also
  # cleans up legacy `.sha1` files from older Shards versions.
  def save
    Dir.mkdir_p(@install_path)

    unless File.exists?(info_path)
      Dir.each_child(@install_path) do |name|
        if name.ends_with?(".sha1")
          File.delete(File.join(@install_path, name))
        end
      end
    end

    File.open(info_path, "w") do |file|
      YAML.build(file) do |yaml|
        yaml.mapping do
          yaml.scalar "version"
          yaml.scalar "1.0"

          yaml.scalar "shards"
          yaml.mapping do
            installed.each do |name, dep|
              dep.to_yaml(yaml)
            end
          end
        end
      end
    end
  end

  # Returns the absolute path to the `.shards.info` file for this instance.
  def info_path
    File.join(@install_path, ".shards.info")
  end
end
