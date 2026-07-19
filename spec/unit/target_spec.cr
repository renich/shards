require "./spec_helper"

module Shards
  describe Target do
    describe ".new(PullParser)" do
      it "parses a target from YAML" do
        yaml = <<-YAML
          myapp:
            main: src/myapp.cr
        YAML
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

      it "ignores unknown properties in YAML" do
        yaml = <<-YAML
          myapp:
            main: src/myapp.cr
            description: my app description
            other_prop: 123
        YAML
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

      it "raises ParseException if main is missing" do
        yaml = <<-YAML
          myapp:
            other_prop: 123
        YAML
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

    describe ".new" do
      it "initializes directly" do
        target = Target.new("test_target", "src/test_main.cr")
        target.name.should eq("test_target")
        target.main.should eq("src/test_main.cr")
      end
    end
  end
end
