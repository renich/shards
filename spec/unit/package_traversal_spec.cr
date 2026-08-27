require "./spec_helper"
require "../../src/package"

module Shards
  describe Package do
    it "prevents path traversal in install_path" do
      resolver = GitResolver.new("evil", "http://github.com/a/a.git")
      package = Package.new("../../evil", resolver, Version.new("1.0.0"))

      expect_raises(Shards::Error, /path traversal detected/) do
        package.install_path
      end
    end
  end
end
