require "./spec_helper"
require "../../src/target"

describe Shards::Target do
  describe ".new(YAML::PullParser)" do
    it "parses a target successfully" do
      yaml = <<-YAML
      app:
        main: src/app.cr
      YAML

      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.each_in_mapping do
            target = Shards::Target.new(pull)
            target.name.should eq("app")
            target.main.should eq("src/app.cr")
          end
        end
      end
    end

    it "ignores unknown properties" do
      yaml = <<-YAML
      app:
        main: src/app.cr
        unknown: property
        other: 123
      YAML

      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.each_in_mapping do
            target = Shards::Target.new(pull)
            target.name.should eq("app")
            target.main.should eq("src/app.cr")
          end
        end
      end
    end

    it "raises when missing main" do
      yaml = <<-YAML
      app:
        not_main: src/app.cr
      YAML

      pull = YAML::PullParser.new(yaml)
      expect_raises(YAML::ParseException, /Missing property "main" for target "app"/) do
        pull.read_stream do
          pull.read_document do
            pull.each_in_mapping do
              Shards::Target.new(pull)
            end
          end
        end
      end
    end

    it "raises when target mapping is empty" do
      yaml = <<-YAML
      app: {}
      YAML

      pull = YAML::PullParser.new(yaml)
      expect_raises(YAML::ParseException, /Missing property "main" for target "app"/) do
        pull.read_stream do
          pull.read_document do
            pull.each_in_mapping do
              Shards::Target.new(pull)
            end
          end
        end
      end
    end
  end
end
