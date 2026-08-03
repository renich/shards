require "./spec_helper"
require "../../src/script"

module Shards
  describe Script do
    it "runs a successful script" do
      Dir.mkdir_p(File.join(tmp_path, "script_test"))
      File.write(File.join(tmp_path, "script_test", "run.sh"), "echo 'hello world'")

      Script.run(File.join(tmp_path, "script_test"), "sh run.sh", "postinstall", "my_dep")
    end

    it "raises an error on failure" do
      Dir.mkdir_p(File.join(tmp_path, "script_test"))
      File.write(File.join(tmp_path, "script_test", "fail.sh"), "echo 'error message' 1>&2\nexit 1")

      expect_raises(Script::Error, "Failed postinstall of my_dep on sh fail.sh:\nerror message") do
        Script.run(File.join(tmp_path, "script_test"), "sh fail.sh", "postinstall", "my_dep")
      end
    end
  end
end
