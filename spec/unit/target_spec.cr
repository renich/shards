require "./spec_helper"

describe Shards::Target do
  describe ".new(YAML::PullParser)" do
    it "parses valid target" do
      yaml = YAML::PullParser.new("foo:\n  main: src/foo.cr")
      yaml.read_stream do
        yaml.read_document do
          yaml.each_in_mapping do
            target = Shards::Target.new(yaml)
            target.name.should eq("foo")
            target.main.should eq("src/foo.cr")
          end
        end
      end
    end

    it "raises when missing main property" do
      yaml = YAML::PullParser.new("foo:\n  other: 1")
      yaml.read_stream do
        yaml.read_document do
          yaml.each_in_mapping do
            expect_raises(YAML::ParseException, /Missing property "main" for target "foo"/) do
              Shards::Target.new(yaml)
            end
          end
        end
      end
    end

    it "ignores unknown properties" do
      yaml = YAML::PullParser.new("foo:\n  main: src/foo.cr\n  unknown: true")
      yaml.read_stream do
        yaml.read_document do
          yaml.each_in_mapping do
            target = Shards::Target.new(yaml)
            target.name.should eq("foo")
            target.main.should eq("src/foo.cr")
          end
        end
      end
    end
  end

  describe ".new" do
    it "initializes with name and main" do
      target = Shards::Target.new("bar", "src/bar.cr")
      target.name.should eq("bar")
      target.main.should eq("src/bar.cr")
    end
  end
end
