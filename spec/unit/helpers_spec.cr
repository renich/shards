require "./spec_helper"
require "../../src/helpers"

describe Shards::Helpers do
  describe ".exe" do
    it "appends .exe on Windows" do
      exp = {% if flag?(:win32) %} "f.exe" {% else %} "f" {% end %}
      Shards::Helpers.exe("f").should eq(exp)
    end
  end

  describe ".rm_rf" do
    it "removes files and directories" do
      p = File.join(Dir.tempdir, "shards_rm_rf")
      Dir.mkdir_p(File.join(p, "d")); File.write(File.join(p, "f"), "a")
      Shards::Helpers.rm_rf(File.join(p, "f")); Shards::Helpers.rm_rf(File.join(p, "d"))
      File.exists?(File.join(p, "f")).should be_false
      Dir.exists?(File.join(p, "d")).should be_false
      Shards::Helpers.rm_rf(p)
    end

    it "removes a symlink without deleting target" do
      p = File.join(Dir.tempdir, "shards_rm_rf_sym")
      Dir.mkdir_p(p); File.write(File.join(p, "t"), "a")
      File.symlink(File.join(p, "t"), File.join(p, "s"))
      Shards::Helpers.rm_rf(File.join(p, "s"))
      File.exists?(File.join(p, "s")).should be_false
      File.exists?(File.join(p, "t")).should be_true
      Shards::Helpers.rm_rf(p)
    end

    it "ignores non-existent paths" do
      Shards::Helpers.rm_rf(File.join(Dir.tempdir, "missing"))
    end
  end

  describe ".rm_rf_children" do
    it "removes children but keeps the directory" do
      p = File.join(Dir.tempdir, "shards_rm_children")
      Dir.mkdir_p(File.join(p, "d")); File.write(File.join(p, "f"), "a")
      Shards::Helpers.rm_rf_children(p)
      Dir.empty?(p).should be_true
      Shards::Helpers.rm_rf(p)
    end
  end
end
