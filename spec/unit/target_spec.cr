require "./spec_helper"
require "../../src/target"

module Shards
  describe Target do
    describe ".new(pull : YAML::PullParser)" do
      it "parses a valid target" do
        yaml = <<-YAML
        app:
          main: src/main.cr
        YAML

        parser = YAML::PullParser.new(yaml)
        target = nil
        parser.read_stream do
          parser.read_document do
            parser.each_in_mapping do
              target = Target.new(parser)
            end
          end
        end

        target.should_not be_nil
        if target
          target.name.should eq("app")
          target.main.should eq("src/main.cr")
        end
      end

      it "ignores unknown properties" do
        yaml = <<-YAML
        app:
          main: src/main.cr
          unknown: some_value
          another: 123
        YAML

        parser = YAML::PullParser.new(yaml)
        target = nil
        parser.read_stream do
          parser.read_document do
            parser.each_in_mapping do
              target = Target.new(parser)
            end
          end
        end

        target.should_not be_nil
        if target
          target.name.should eq("app")
          target.main.should eq("src/main.cr")
        end
      end

      it "raises YAML::ParseException when main is missing" do
        yaml = <<-YAML
        app:
          unknown: some_value
        YAML

        parser = YAML::PullParser.new(yaml)
        expect_raises(YAML::ParseException, /Missing property "main" for target "app"/) do
          parser.read_stream do
            parser.read_document do
              parser.each_in_mapping do
                Target.new(parser)
              end
            end
          end
        end
      end
    end

    describe "#initialize" do
      it "creates a new target" do
        target = Target.new("app", "src/app.cr")
        target.name.should eq("app")
        target.main.should eq("src/app.cr")
      end
    end
  end
end
