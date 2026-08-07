require "./spec_helper"
require "../../src/target"

describe Shards::Target do
  describe ".new(YAML::PullParser)" do
    it "parses a target mapping correctly" do
      pull = YAML::PullParser.new(%(
        app:
          main: src/app.cr
      ))
      pull.read_stream_start
      pull.read_document_start
      pull.read_mapping_start

      target = Shards::Target.new(pull)
      target.name.should eq("app")
      target.main.should eq("src/app.cr")
    end

    it "raises when main is missing" do
      pull = YAML::PullParser.new(%(
        app:
          other: src/app.cr
      ))
      pull.read_stream_start
      pull.read_document_start
      pull.read_mapping_start

      expect_raises(YAML::ParseException, /Missing property "main" for target "app"/) do
        Shards::Target.new(pull)
      end
    end

    it "ignores unknown target mapping for future extensions" do
      pull = YAML::PullParser.new(%(
        app:
          main: src/app.cr
          other: ignore_me
      ))
      pull.read_stream_start
      pull.read_document_start
      pull.read_mapping_start

      target = Shards::Target.new(pull)
      target.name.should eq("app")
      target.main.should eq("src/app.cr")
    end
  end
end
