require "./spec_helper"
require "yaml"

describe Shards::Target do
  describe ".new" do
    it "initializes with name and main properties directly" do
      target = Shards::Target.new("app", "src/app.cr")
      target.name.should eq("app")
      target.main.should eq("src/app.cr")
    end

    it "parses from a YAML::PullParser" do
      yaml = <<-YAML
        app:
          main: src/app.cr
      YAML

      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.read_mapping do
            target = Shards::Target.new(pull)
            target.name.should eq("app")
            target.main.should eq("src/app.cr")
          end
        end
      end
    end

    it "ignores unknown keys in YAML" do
      yaml = <<-YAML
        app:
          main: src/app.cr
          extra: ignored_value
      YAML

      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.read_mapping do
            target = Shards::Target.new(pull)
            target.name.should eq("app")
            target.main.should eq("src/app.cr")
          end
        end
      end
    end

    it "raises YAML::ParseException when main is missing" do
      yaml = <<-YAML
        app:
          extra: value
      YAML

      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.read_mapping do
            expect_raises(YAML::ParseException, %{Missing property "main" for target "app"}) do
              Shards::Target.new(pull)
            end
          end
        end
      end
    end
  end
end
