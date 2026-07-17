require "./spec_helper"
require "../../src/target"

module Shards
  describe Target do
    it "initializes with name and main" do
      target = Target.new("app", "src/app.cr")
      target.name.should eq("app")
      target.main.should eq("src/app.cr")
    end

    it "parses from yaml" do
      yaml = "app:\n  main: src/app.cr"
      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.read_mapping do
            target = Target.new(pull)
            target.name.should eq("app")
            target.main.should eq("src/app.cr")
          end
        end
      end
    end

    it "raises exception if main is missing" do
      yaml = "app:\n  other: src/app.cr"
      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.read_mapping do
            expect_raises(YAML::ParseException, %(Missing property "main" for target "app")) do
              Target.new(pull)
            end
          end
        end
      end
    end

    it "ignores unknown mapping for future extensions" do
      yaml = "app:\n  main: src/app.cr\n  description: my app"
      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.read_mapping do
            target = Target.new(pull)
            target.name.should eq("app")
            target.main.should eq("src/app.cr")
          end
        end
      end
    end
  end
end
