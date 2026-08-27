require "./spec_helper"
require "../../src/helpers"

describe Shards::Helpers do
  describe ".exe" do
    it "returns the name with .exe extension on Windows, and untouched elsewhere" do
      {% if flag?(:win32) %}
        Shards::Helpers.exe("foo").should eq("foo.exe")
      {% else %}
        Shards::Helpers.exe("foo").should eq("foo")
      {% end %}
    end
  end

  describe ".rm_rf" do
    it "removes a regular file" do
      path = File.join(Dir.tempdir, "shards_helpers_file")
      File.write(path, "test")
      File.exists?(path).should be_true
      Shards::Helpers.rm_rf(path)
      File.exists?(path).should be_false
    end

    it "removes an empty directory" do
      path = File.join(Dir.tempdir, "shards_helpers_dir")
      Dir.mkdir_p(path)
      Dir.exists?(path).should be_true
      Shards::Helpers.rm_rf(path)
      Dir.exists?(path).should be_false
    end

    it "removes a directory with files and subdirectories" do
      path = File.join(Dir.tempdir, "shards_helpers_tree")
      Dir.mkdir_p(File.join(path, "sub"))
      File.write(File.join(path, "file.txt"), "a")
      File.write(File.join(path, "sub", "file2.txt"), "b")

      Dir.exists?(path).should be_true
      Shards::Helpers.rm_rf(path)
      Dir.exists?(path).should be_false
    end

    it "removes a symlink without deleting its target" do
      target_path = File.join(Dir.tempdir, "shards_helpers_target")
      link_path = File.join(Dir.tempdir, "shards_helpers_link")
      File.write(target_path, "target")

      # Try to create symlink
      begin
        File.symlink(target_path, link_path)
      rescue NotImplementedError
        # Symlinks might not be supported
      end

      if File.symlink?(link_path)
        Shards::Helpers.rm_rf(link_path)
        File.exists?(link_path).should be_false
        File.exists?(target_path).should be_true
      end

      File.delete(target_path) if File.exists?(target_path)
    end

    it "ignores non-existent paths silently" do
      path = File.join(Dir.tempdir, "shards_helpers_not_exist")
      File.exists?(path).should be_false
      # Should not raise
      Shards::Helpers.rm_rf(path)
    end
  end

  describe ".rm_rf_children" do
    it "removes all children of a directory but keeps the directory itself" do
      path = File.join(Dir.tempdir, "shards_helpers_children_tree")
      Dir.mkdir_p(File.join(path, "sub"))
      File.write(File.join(path, "file.txt"), "a")
      File.write(File.join(path, "sub", "file2.txt"), "b")

      Dir.exists?(path).should be_true
      Shards::Helpers.rm_rf_children(path)

      Dir.exists?(path).should be_true
      Dir.empty?(path).should be_true

      Dir.delete(path)
    end
  end
end
