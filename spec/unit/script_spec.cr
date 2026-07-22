require "./spec_helper"
require "../../src/script"
require "file_utils"

module Shards
  describe Script do
    describe ".run" do
      it "runs the script successfully" do
        Dir.mkdir_p(File.join(tmp_path, "script_repo"))
        Dir.cd(File.join(tmp_path, "script_repo")) do
          Script.run(".", "echo 'hello world'", "postinstall", "my_dep")
        end
      end

      it "raises an error if the script fails" do
        Dir.mkdir_p(File.join(tmp_path, "script_repo"))
        Dir.cd(File.join(tmp_path, "script_repo")) do
          expect_raises(Script::Error, /Failed postinstall of my_dep on false/) do
            Script.run(".", "false", "postinstall", "my_dep")
          end
        end
      end

      it "includes the output in the error message" do
        Dir.mkdir_p(File.join(tmp_path, "script_repo"))
        Dir.cd(File.join(tmp_path, "script_repo")) do
          expect_raises(Script::Error, /Failed postinstall of my_dep on echo 'hello error' && false:\nhello error/) do
            Script.run(".", "echo 'hello error' && false", "postinstall", "my_dep")
          end
        end
      end
    end
  end
end
