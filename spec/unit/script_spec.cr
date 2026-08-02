require "./spec_helper"
require "../../src/script"

describe Shards::Script do
  describe ".run" do
    it "runs a valid script successfully" do
      Shards::Script.run(tmp_path, "echo 'hello'", "test_script", "test_dependency")
    end

    it "raises Script::Error on failure" do
      expect_raises(Shards::Script::Error, /Failed test_script of test_dependency on false/) do
        Shards::Script.run(tmp_path, "false", "test_script", "test_dependency")
      end
    end

    it "raises Script::Error capturing output" do
      expect_raises(Shards::Script::Error, /Failed test_script of test_dependency on echo 'error' && false:\nerror/) do
        Shards::Script.run(tmp_path, "echo 'error' && false", "test_script", "test_dependency")
      end
    end

    it "runs in the specified directory" do
      dir_name = File.basename(tmp_path)
      # Check if the path printed by pwd ends with the basename of tmp_path
      # Note: tmp_path might be absolute or relative, but `pwd` will be absolute.
      # And on Windows it might have backslashes. Using a simpler approach:

      expect_raises(Shards::Script::Error, /Failed test_script of test_dependency on pwd && false:\n.*#{Regex.escape(dir_name)}/) do
        Shards::Script.run(tmp_path, "pwd && false", "test_script", "test_dependency")
      end
    end
  end
end
