require "./spec_helper"
require "../../src/target"

describe Shards::Target do
  describe ".new(YAML::PullParser)" do
    it "parses target with name and main" do
      yaml = <<-YAML
      my_target:
        main: src/main.cr
      YAML

      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.each_in_mapping do
            target = Shards::Target.new(pull)
            target.name.should eq("my_target")
            target.main.should eq("src/main.cr")
          end
        end
      end
    end

    it "raises when main is missing" do
      yaml = <<-YAML
      my_target:
        foo: bar
      YAML

      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.each_in_mapping do
            expect_raises(YAML::ParseException, %q(Missing property "main" for target "my_target")) do
              Shards::Target.new(pull)
            end
          end
        end
      end
    end

    it "ignores unknown properties" do
      yaml = <<-YAML
      my_target:
        main: src/main.cr
        other: value
      YAML

      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.each_in_mapping do
            target = Shards::Target.new(pull)
            target.name.should eq("my_target")
            target.main.should eq("src/main.cr")
          end
        end
      end
    end
  end
end
