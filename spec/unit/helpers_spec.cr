require "./spec_helper"
require "../../src/helpers"

describe Shards::Helpers do
  describe ".rm_rf_children" do
    it "removes children of a directory but keeps the directory itself" do
      # Create a temporary directory
      dir = File.join(Dir.tempdir, "shards_helpers_test_#{Time.utc.to_unix_ms}")
      Dir.mkdir_p(dir)

      begin
        # Create files and subdirectories
        File.write(File.join(dir, "file1.txt"), "hello")
        subdir = File.join(dir, "subdir")
        Dir.mkdir_p(subdir)
        File.write(File.join(subdir, "file2.txt"), "world")

        Shards::Helpers.rm_rf_children(dir)

        Dir.exists?(dir).should be_true
        Dir.empty?(dir).should be_true
      ensure
        Shards::Helpers.rm_rf(dir)
      end
    end

    it "does not fail if directory is already empty" do
      dir = File.join(Dir.tempdir, "shards_helpers_test_empty_#{Time.utc.to_unix_ms}")
      Dir.mkdir_p(dir)

      begin
        Shards::Helpers.rm_rf_children(dir)

        Dir.exists?(dir).should be_true
        Dir.empty?(dir).should be_true
      ensure
        Shards::Helpers.rm_rf(dir)
      end
    end
  end
end
