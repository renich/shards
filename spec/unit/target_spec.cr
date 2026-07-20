require "./spec_helper"

module Shards
  describe Target do
    describe ".new" do
      it "parses from YAML pull parser" do
        yaml = <<-YAML
        app:
          main: src/app.cr
        YAML

        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.each_in_mapping do
              target = Target.new(pull)
              target.name.should eq("app")
              target.main.should eq("src/app.cr")
            end
          end
        end
      end

      it "raises error if main property is missing" do
        yaml = <<-YAML
        app:
          foo: bar
        YAML

        pull = YAML::PullParser.new(yaml)
        pull.read_stream do
          pull.read_document do
            pull.each_in_mapping do
              expect_raises(YAML::ParseException, /Missing property "main" for target "app"/) do
                Target.new(pull)
              end
            end
          end
        end
      end
    end
  end
end
