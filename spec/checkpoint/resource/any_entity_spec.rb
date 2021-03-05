# frozen_string_literal: true

require "checkpoint/resource/any_entity"

RSpec.describe Checkpoint::Resource::AnyEntity do
  it "is eql? to itself" do
    anything = described_class.new
    expect(anything).to eql anything
  end

  it "is == to itself" do
    anything = described_class.new
    expect(anything).to eq anything
  end

  it "is eql? to another instance of AnyEntity" do
    one = described_class.new
    two = described_class.new
    expect(one).to eql two
  end

  it "is == to another instance of AnyEntity" do
    one = described_class.new
    two = described_class.new
    expect(one).to eq two
  end

  it "is eql? to a plain Object" do
    one = described_class.new
    two = Object.new
    expect(one).to eql two
  end

  it "is == to a plain Object" do
    one = described_class.new
    two = Object.new
    expect(one).to eq two
  end
end
