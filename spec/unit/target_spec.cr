require "./spec_helper"

module Shards
  describe Target do
    it "parses a target with a main property" do
      target = parse_target({"shards" => {"main" => "src/shards.cr"}})
      target.name.should eq("shards")
      target.main.should eq("src/shards.cr")
    end

    it "ignores unknown properties" do
      target = parse_target({"shards" => {"main" => "src/shards.cr", "foo" => "bar"}})
      target.name.should eq("shards")
      target.main.should eq("src/shards.cr")
    end

    it "raises when missing main property" do
      expect_raises(YAML::ParseException, "Missing property \"main\" for target \"shards\"") do
        parse_target({"shards" => {"foo" => "bar"}})
      end
    end
  end
end

private def parse_target(hash)
  pull = YAML::PullParser.new(hash.to_yaml)
  pull.read_stream do
    pull.read_document do
      pull.read_mapping do
        return Shards::Target.new(pull)
      end
    end
  end
  raise "unreachable"
end
