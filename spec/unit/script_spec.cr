require "./spec_helper"
require "file_utils"

module Shards
  describe Script do
    describe ".run" do
      it "runs a successful command" do
        path = File.join(Dir.tempdir, "script_test_#{Time.utc.to_unix_ms}")
        Dir.mkdir_p(path)
        begin
          Script.run(path, "echo success", "postinstall", "test_dep")
        ensure
          FileUtils.rm_rf(path)
        end
      end

      it "raises an error if the command fails" do
        path = File.join(Dir.tempdir, "script_test_#{Time.utc.to_unix_ms}")
        Dir.mkdir_p(path)
        begin
          expect_raises(Script::Error, /Failed postinstall of test_dep on false:\n?/) do
            Script.run(path, "false", "postinstall", "test_dep")
          end
        ensure
          FileUtils.rm_rf(path)
        end
      end

      it "includes output in the error message" do
        path = File.join(Dir.tempdir, "script_test_#{Time.utc.to_unix_ms}")
        Dir.mkdir_p(path)
        begin
          expect_raises(Script::Error, /Failed postinstall of test_dep on echo fail && false:\nfail/) do
            Script.run(path, "echo fail && false", "postinstall", "test_dep")
          end
        ensure
          FileUtils.rm_rf(path)
        end
      end
    end
  end
end
