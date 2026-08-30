require "../../unit/spec_helper"
require "../../../src/ext/yaml"

describe YAML::PullParser do
  describe "#each_in_sequence" do
    it "yields each element in the sequence" do
      yaml = "---\n- a\n- b\n- c\n"
      parser = YAML::PullParser.new(yaml)

      items = [] of String
      parser.read_stream do
        parser.read_document do
          parser.each_in_sequence do
            items << parser.value
            parser.read_next
          end
        end
      end

      items.should eq(["a", "b", "c"])
    end
  end

  describe "#each_in_mapping" do
    it "yields each key-value pair in the mapping" do
      yaml = "---\na: 1\nb: 2\n"
      parser = YAML::PullParser.new(yaml)

      items = {} of String => String
      parser.read_stream do
        parser.read_document do
          parser.each_in_mapping do
            key = parser.value
            parser.read_next
            value = parser.value
            parser.read_next
            items[key] = value
          end
        end
      end

      items.should eq({"a" => "1", "b" => "2"})
    end
  end

  describe "#read_empty_or" do
    it "skips empty or null values" do
      yaml = "---\na: \nb: ~\n"
      parser = YAML::PullParser.new(yaml)

      items = [] of String
      parser.read_stream do
        parser.read_document do
          parser.each_in_mapping do
            parser.read_next

            called = false
            parser.read_empty_or do
              called = true
              parser.read_next
            end
            items << called.to_s
          end
        end
      end

      items.should eq(["false", "false"])
    end

    it "yields if the value is not empty or null" do
      yaml = "---\na: 1\n"
      parser = YAML::PullParser.new(yaml)

      parser.read_stream do
        parser.read_document do
          parser.each_in_mapping do
            parser.read_next

            called = false
            parser.read_empty_or do
              called = true
              parser.read_next
            end
            called.should be_true
          end
        end
      end
    end
  end
end
