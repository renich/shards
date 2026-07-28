require "./spec_helper"

describe Shards::Target do
  describe ".new(YAML::PullParser)" do
    it "parses target from YAML" do
      pull = YAML::PullParser.new("target_name:\n  main: src/main.cr\n")
      pull.read_stream do
        pull.read_document do
          pull.each_in_mapping do
            target = Shards::Target.new(pull)
            target.name.should eq("target_name")
            target.main.should eq("src/main.cr")
          end
        end
      end
    end

    it "raises exception when main is missing" do
      pull = YAML::PullParser.new("target_name:\n  other: src/main.cr\n")
      pull.read_stream do
        pull.read_document do
          pull.each_in_mapping do
            expect_raises(YAML::ParseException, /Missing property "main" for target "target_name"/) do
              Shards::Target.new(pull)
            end
          end
        end
      end
    end

    it "ignores unknown properties" do
      pull = YAML::PullParser.new("target_name:\n  main: src/main.cr\n  other: value\n")
      pull.read_stream do
        pull.read_document do
          pull.each_in_mapping do
            target = Shards::Target.new(pull)
            target.name.should eq("target_name")
            target.main.should eq("src/main.cr")
          end
        end
      end
    end
  end

  describe "#initialize" do
    it "assigns name and main" do
      target = Shards::Target.new("target_name", "src/main.cr")
      target.name.should eq("target_name")
      target.main.should eq("src/main.cr")
    end
  end
end
