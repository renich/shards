require "./spec_helper"

describe Shards::Package do
  it "prevents path traversal in package name" do
    expect_raises(Shards::Error, /Invalid package name/) do
      Shards::Package.new("../../../tmp/hacked", Shards::PathResolver.new("../../../tmp/hacked", "."), Shards::Version.new("1.0.0")).install_path
    end
  end
end
