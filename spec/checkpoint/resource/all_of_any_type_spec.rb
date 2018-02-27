# frozen_string_literal: true

require 'checkpoint/resource/all_of_any_type'

RSpec.describe Checkpoint::Resource::AllOfAnyType do
  it 'has the ALL type' do
    resource = described_class.new
    expect(resource.type).to eq Checkpoint::Resource::ALL
  end

  it 'has the ALL id' do
    resource = described_class.new
    expect(resource.id).to eq Checkpoint::Resource::ALL
  end

  describe '::from' do
    it 'disregards the entity type (promoting it to ALL)' do
      resource = described_class.from(double('entity', type: 'type', id: 'id') )
      expect(resource.type).to eq Checkpoint::Resource::ALL
    end

    it 'disregards the entity id (promoting it to ALL)' do
      resource = described_class.from(double('entity', type: 'type', id: 'id') )
      expect(resource.id).to eq Checkpoint::Resource::ALL
    end
  end
end
