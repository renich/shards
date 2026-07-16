require "./spec_helper"

describe Shards::Target do
  describe ".new(YAML::PullParser)" do
    it "parses a target with main and ignores extra keys" do
      yaml = "my_target:\n  main: src/main.cr\n  extra: val\n"
      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.read_mapping do
            target = Shards::Target.new(pull)
            target.name.should eq("my_target")
            target.main.should eq("src/main.cr")
          end
        end
      end
    end

    it "raises when main is missing" do
      yaml = "my_target:\n  other: val\n"
      pull = YAML::PullParser.new(yaml)
      expect_raises(YAML::ParseException, %{Missing property "main" for target "my_target"}) do
        pull.read_stream do
          pull.read_document do
            pull.read_mapping do
              Shards::Target.new(pull)
            end
          end
        end
      end
    end
  end

  describe "#initialize" do
    it "initializes correctly" do
      target = Shards::Target.new("name", "main.cr")
      target.name.should eq("name")
      target.main.should eq("main.cr")
    end
  end
end
