require "./spec_helper"
require "../../src/target"

module Shards
  describe Target do
    describe ".new(YAML::PullParser)" do
      it "parses target with main" do
        yaml = <<-YAML
        app:
          main: src/app.cr
        YAML

        pull = YAML::PullParser.new(yaml)
        pull.read_stream_start
        pull.read_document_start
        pull.read_mapping_start
        target = Target.new(pull)

        target.name.should eq("app")
        target.main.should eq("src/app.cr")
      end

      it "raises YAML::ParseException when main is missing" do
        yaml = <<-YAML
        app:
          other: src/app.cr
        YAML

        pull = YAML::PullParser.new(yaml)
        pull.read_stream_start
        pull.read_document_start
        pull.read_mapping_start

        expect_raises(YAML::ParseException, %q(Missing property "main" for target "app")) do
          Target.new(pull)
        end
      end
    end

    describe "#initialize" do
      it "initializes with name and main" do
        target = Target.new("app", "src/app.cr")
        target.name.should eq("app")
        target.main.should eq("src/app.cr")
      end
    end
  end
end
