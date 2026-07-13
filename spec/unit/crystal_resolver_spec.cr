require "./spec_helper"

module Shards
  describe CrystalResolver do
    it "has the correct key" do
      CrystalResolver.key.should eq("crystal")
    end

    it "returns the current crystal version as available releases" do
      resolver = CrystalResolver.new("crystal", "")
      releases = resolver.available_releases
      releases.size.should eq(1)
      releases.first.value.should eq(Shards.crystal_version)
    end

    it "returns nil for read_spec" do
      resolver = CrystalResolver.new("crystal", "")
      resolver.read_spec(Version.new(Shards.crystal_version)).should be_nil
    end

    it "raises NotImplementedError on install_sources" do
      resolver = CrystalResolver.new("crystal", "")
      expect_raises(NotImplementedError, "CrystalResolver#install_sources") do
        resolver.install_sources(Version.new(Shards.crystal_version), "/tmp/install")
      end
    end

    it "reports version correctly" do
      resolver = CrystalResolver.new("crystal", "")
      resolver.report_version(Version.new("1.2.3")).should eq("1.2.3")
    end
  end
end
