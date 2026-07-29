require "./spec_helper"
require "yaml"

module Shards
  describe Target do
    describe ".new(YAML::PullParser)" do
      it "parses a target with name and main" do
        yaml = <<-YAML
        my_target:
          main: src/my_target.cr
        YAML

        parser = YAML::PullParser.new(yaml)
        parser.read_stream do
          parser.read_document do
            parser.each_in_mapping do
              target = Target.new(parser)
              target.name.should eq("my_target")
              target.main.should eq("src/my_target.cr")
            end
          end
        end
      end

      it "ignores unknown properties" do
        yaml = <<-YAML
        my_target:
          main: src/main.cr
          unknown: ignore_me
        YAML

        parser = YAML::PullParser.new(yaml)
        parser.read_stream do
          parser.read_document do
            parser.each_in_mapping do
              target = Target.new(parser)
              target.name.should eq("my_target")
              target.main.should eq("src/main.cr")
            end
          end
        end
      end

      it "raises when main is missing" do
        yaml = <<-YAML
        my_target:
          description: A target without main
        YAML

        parser = YAML::PullParser.new(yaml)
        expect_raises(YAML::ParseException, %{Missing property "main" for target "my_target"}) do
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
      it "initializes with name and main" do
        target = Target.new("test_target", "src/test.cr")
        target.name.should eq("test_target")
        target.main.should eq("src/test.cr")
      end
    end
  end
end
