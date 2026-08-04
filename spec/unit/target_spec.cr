require "./spec_helper"
require "../../src/target"

module Shards
  describe Target do
    describe ".new(pull : YAML::PullParser)" do
      it "parses a valid target" do
        yaml = <<-YAML
        target_name:
          main: src/main.cr
        YAML

        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.each_in_mapping do
              target = Target.new(pull)
              target.name.should eq("target_name")
              target.main.should eq("src/main.cr")
            end
          end
        end
      end

      it "raises when missing main property" do
        yaml = <<-YAML
        target_name:
          other: src/main.cr
        YAML

        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.each_in_mapping do
              expect_raises(YAML::ParseException, %{Missing property "main" for target "target_name"}) do
                Target.new(pull)
              end
            end
          end
        end
      end

      it "ignores unknown properties (future extensions)" do
        yaml = <<-YAML
        target_name:
          description: "An example target"
          main: src/main.cr
        YAML

        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.each_in_mapping do
              target = Target.new(pull)
              target.name.should eq("target_name")
              target.main.should eq("src/main.cr")
            end
          end
        end
      end
    end

    describe "#initialize" do
      it "creates a target with name and main properties" do
        target = Target.new("app", "src/app.cr")
        target.name.should eq("app")
        target.main.should eq("src/app.cr")
      end
    end
  end
end
