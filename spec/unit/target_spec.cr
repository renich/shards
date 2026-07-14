require "./spec_helper"

module Shards
  describe Target do
    describe ".new(pull)" do
      it "parses target with main property" do
        yaml = <<-YAML
        my_target:
          main: src/my_target.cr
        YAML

        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.each_in_mapping do
              target = Target.new(pull)
              target.name.should eq("my_target")
              target.main.should eq("src/my_target.cr")
            end
          end
        end
      end

      it "raises when main property is missing" do
        yaml = <<-YAML
        my_target:
          main2: src/my_target.cr
        YAML

        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.each_in_mapping do
              expect_raises(YAML::ParseException, %(Missing property "main" for target "my_target")) do
                Target.new(pull)
              end
            end
          end
        end
      end
    end

    describe ".new" do
      it "initializes directly" do
        target = Target.new("app", "src/app.cr")
        target.name.should eq("app")
        target.main.should eq("src/app.cr")
      end
    end
  end
end
