# frozen_string_literal: true

require "checkpoint/resource/any_entity_of_type"

RSpec.describe Checkpoint::Resource::AnyEntityOfType do
  it "is eql? to itself" do
    entity = described_class.new("type")
    expect(entity).to eql entity
  end

  it "is == to itself" do
    entity = described_class.new("type")
    expect(entity).to eq entity
  end

  it "is eql? to another instance of for the same type" do
    one = described_class.new("type")
    two = described_class.new("type")
    expect(one).to eql two
  end

  it "is == to another instance of for the same type" do
    one = described_class.new("type")
    two = described_class.new("type")
    expect(one).to eq two
  end

  it "is eql? to anything with the the same #type" do
    one = described_class.new("type")
    two = double("entity", type: "type")
    expect(one).to eql two
  end

  it "is == to anything with the the same #type" do
    one = described_class.new("type")
    two = double("entity", type: "type")
    expect(one).to eq two
  end
end
