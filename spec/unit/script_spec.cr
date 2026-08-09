require "./spec_helper"
require "../../src/script"

module Shards
  describe Script do
    describe ".run" do
      it "runs the command successfully and returns nothing" do
        Dir.mkdir_p(tmp_path)
        Script.run(tmp_path, "echo 'hello'", "test_script", "test_dependency").should be_nil
      end

      it "raises Script::Error when the command fails" do
        Dir.mkdir_p(tmp_path)
        expect_raises(Script::Error, /Failed test_script of test_dependency on false:/) do
          Script.run(tmp_path, "false", "test_script", "test_dependency")
        end
      end

      it "includes output in the error message when the command fails" do
        Dir.mkdir_p(tmp_path)
        expect_raises(Script::Error, /Failed test_script of test_dependency on echo 'some error' && false:\nsome error/) do
          Script.run(tmp_path, "echo 'some error' && false", "test_script", "test_dependency")
        end
      end
    end
  end
end
