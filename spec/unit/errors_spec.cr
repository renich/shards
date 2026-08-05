require "./spec_helper"
require "../../src/errors"

module Shards
  describe ParseError do
    it "renders the error message correctly" do
      input = "line 1\nline 2\nline 3\nbad line\nline 5"
      error = ParseError.new("something went wrong", input, "shard.yml", 4, 3)

      io = IO::Memory.new
      Colorize.enabled = false
      error.to_s(io)
      output = io.to_s

      expected = <<-OUT
Error in shard.yml: something went wrong

  2. line 2
  3. line 3
  4. bad line
       ^


OUT
      output.should eq(expected)
    end

    it "handles line_number less than 3" do
      input = "line 1\nline 2\nline 3"
      error = ParseError.new("first line error", input, "shard.yml", 1, 1)

      io = IO::Memory.new
      Colorize.enabled = false
      error.to_s(io)
      output = io.to_s

      expected = <<-OUT
Error in shard.yml: first line error

  1. line 1
     ^


OUT
      output.should eq(expected)
    end

    it "renders correctly with a resolver" do
      input = "line 1\nline 2"
      error = ParseError.new("bad parse", input, "shard.yml", 2, 2)

      resolver = PathResolver.new("my_shard", "src/")
      error.resolver = resolver

      io = IO::Memory.new
      Colorize.enabled = false
      error.to_s(io)
      output = io.to_s

      expected = <<-OUT
Error in my_shard:shard.yml: bad parse

  1. line 1
  2. line 2
      ^


OUT
      output.should eq(expected)
    end
  end

  describe LockConflict do
    it "initializes with the correct message" do
      error = LockConflict.new("missing dependencies")
      error.message.should eq("Outdated shard.lock (missing dependencies). Please run shards update instead.")
    end
  end

  describe InvalidLock do
    it "initializes with the correct message" do
      error = InvalidLock.new
      error.message.should eq("Unsupported shard.lock. It was likely generated from a newer version of Shards.")
    end
  end
end
