require "./spec_helper"

describe Shards::Target do
  describe ".new(YAML::PullParser)" do
    it "parses from yaml" do
      yaml = <<-YAML
      mytarget:
        main: src/main.cr
      YAML

      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.each_in_mapping do
            target = Shards::Target.new(pull)
            target.name.should eq("mytarget")
            target.main.should eq("src/main.cr")
          end
        end
      end
    end

    it "raises when missing main property" do
      yaml = <<-YAML
      mytarget:
        description: A target
      YAML

      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.each_in_mapping do
            expect_raises(YAML::ParseException, /Missing property "main" for target "mytarget"/) do
              Shards::Target.new(pull)
            end
          end
        end
      end
    end

    it "ignores unknown properties" do
      yaml = <<-YAML
      mytarget:
        main: src/main.cr
        foo: bar
      YAML

      pull = YAML::PullParser.new(yaml)
      pull.read_stream do
        pull.read_document do
          pull.each_in_mapping do
            target = Shards::Target.new(pull)
            target.name.should eq("mytarget")
            target.main.should eq("src/main.cr")
          end
        end
      end
    end
  end

  describe ".new" do
    it "initializes" do
      target = Shards::Target.new("mytarget", "src/main.cr")
      target.name.should eq("mytarget")
      target.main.should eq("src/main.cr")
    end
  end
end
