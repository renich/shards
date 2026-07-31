require "./spec_helper"

module Shards
  describe Target do
    describe "#initialize" do
      it "initializes with name and main" do
        target = Target.new("myapp", "src/main.cr")
        target.name.should eq("myapp")
        target.main.should eq("src/main.cr")
      end
    end

    describe ".new(YAML::PullParser)" do
      it "parses from YAML correctly" do
        yaml = "myapp:\n  main: src/myapp.cr\n  other: ignored"
        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.each_in_mapping do
              target = Target.new(pull)
              target.name.should eq("myapp")
              target.main.should eq("src/myapp.cr")
            end
          end
        end
      end

      it "raises when main is missing" do
        yaml = "myapp:\n  other: value"
        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.each_in_mapping do
              expect_raises(YAML::ParseException, %(Missing property "main" for target "myapp")) do
                Target.new(pull)
              end
            end
          end
        end
      end
    end
  end
end
