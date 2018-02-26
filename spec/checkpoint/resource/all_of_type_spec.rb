# frozen_string_literal: true

require 'checkpoint/resource/all_of_type'

RSpec.describe Checkpoint::Resource::AllOfType do
  context 'with a generic entity' do
    it 'uses the type from the entity' do
      entity = double('entity', class: 'Entity', id: 'id')
      resource = described_class.new(entity)
      expect(resource.type).to eq 'Entity'
    end

    it 'uses the ALL constant as the id' do
      entity = double('entity', class: 'Entity', id: 'id')
      resource = described_class.new(entity)
      expect(resource.id).to eq Checkpoint::Resource::ALL
    end
  end

  context 'with an entity implementing #to_resource' do
    let(:entity)          { double('entity', to_resource: entity_resource) }
    let(:entity_resource) { double('entity_resource', type: 'type', id: 'id') }
    let(:resource)        { described_class.from(entity) }

    it 'converts to a wildcard based on the resource given by the entity' do
      expect(resource).to be_a described_class
    end

    it 'uses the ALL constant as the id' do
      expect(resource.id).to eq Checkpoint::Resource::ALL
    end
  end
end
