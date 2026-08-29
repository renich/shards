require "../spec_helper"
require "../../../src/ext/yaml"

describe YAML::PullParser do
  describe "#each_in_sequence" do
    it "yields on each new entry until the sequence is terminated" do
      yaml = "---\n- a\n- b\n"
      pull = YAML::PullParser.new(yaml)
      pull.read_stream_start
      pull.read_document_start
      res = [] of String
      pull.each_in_sequence do
        res << pull.read_scalar
      end
      res.should eq(["a", "b"])
    end
  end

  describe "#each_in_mapping" do
    it "yields on each new entry until the mapping is terminated" do
      yaml = "---\na: 1\nb: 2\n"
      pull = YAML::PullParser.new(yaml)
      pull.read_stream_start
      pull.read_document_start
      res = [] of String
      pull.each_in_mapping do
        res << pull.read_scalar
        res << pull.read_scalar
      end
      res.should eq(["a", "1", "b", "2"])
    end
  end

  describe "#read_empty_or" do
    it "skips empty strings" do
      yaml = "---\n\"\"\n"
      pull = YAML::PullParser.new(yaml)
      pull.read_stream_start
      pull.read_document_start
      called = false
      pull.read_empty_or do
        called = true
      end
      called.should be_false
    end

    it "skips tilde (~)" do
      yaml = "---\n~\n"
      pull = YAML::PullParser.new(yaml)
      pull.read_stream_start
      pull.read_document_start
      called = false
      pull.read_empty_or do
        called = true
      end
      called.should be_false
    end

    it "yields if not empty" do
      yaml = "---\nvalue\n"
      pull = YAML::PullParser.new(yaml)
      pull.read_stream_start
      pull.read_document_start
      called = false
      pull.read_empty_or do
        called = true
      end
      called.should be_true
    end
  end
end
