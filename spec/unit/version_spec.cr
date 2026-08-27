require "./spec_helper"

module Shards
  describe Version do
    it "initializes correctly" do
      version = Version.new("1.0.0")
      version.value.should eq("1.0.0")
    end

    it "to_s" do
      version = Version.new("1.0.0")
      version.to_s.should eq("1.0.0")
    end

    it "has_metadata?" do
      Version.new("1.0.0").has_metadata?.should be_false
      Version.new("1.0.0+build1").has_metadata?.should be_true
    end

    it "prerelease?" do
      Version.new("1.0.0").prerelease?.should be_false
      Version.new("1.0.0-rc1").prerelease?.should be_true
    end

    it "to_yaml" do
      version = Version.new("1.0.0")
      yaml = YAML.build do |builder|
        builder.mapping do
          version.to_yaml(builder)
        end
      end
      yaml.should eq("---\nversion: 1.0.0\n")
    end
  end

  describe Any do
    it "to_s" do
      Any.to_s.should eq("*")
    end
  end
end
