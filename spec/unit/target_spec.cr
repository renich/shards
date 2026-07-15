require "./spec_helper"
require "../../src/target"

module Shards
  describe Target do
    describe ".new(pull : YAML::PullParser)" do
      it "parses a target successfully" do
        yaml = %({"shards": {"main": "src/shards.cr"}})
        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.read_mapping do
              target = Target.new(pull)
              target.name.should eq("shards")
              target.main.should eq("src/shards.cr")
            end
          end
        end
      end

      it "ignores unknown dependency mapping" do
        yaml = %({"shards": {"main": "src/shards.cr", "other": "value"}})
        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.read_mapping do
              target = Target.new(pull)
              target.name.should eq("shards")
              target.main.should eq("src/shards.cr")
            end
          end
        end
      end

      it "raises YAML::ParseException when main is missing" do
        yaml = %({"shards": {"other": "value"}})
        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.read_mapping do
              expect_raises(YAML::ParseException, %(Missing property "main" for target "shards")) do
                Target.new(pull)
              end
            end
          end
        end
      end
    end

    describe "#initialize" do
      it "creates a target" do
        target = Target.new("cli", "src/cli.cr")
        target.name.should eq("cli")
        target.main.should eq("src/cli.cr")
      end
    end
  end
end
