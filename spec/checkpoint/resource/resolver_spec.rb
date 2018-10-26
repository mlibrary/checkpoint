# frozen_string_literal: true

require 'checkpoint/resource/resolver'

RSpec.describe Checkpoint::Resource::Resolver do
  let(:resolver) { described_class.new }

  context 'with an entity' do
    let(:listing)       { double('Listing', id: 12, resource_type: 'listing') }
    subject(:resources) { resolver.expand(listing) }

    it 'resolves to only the entity and type resources' do
      entity   = Checkpoint::Resource.new(listing)
      wildcard = Checkpoint::Resource::AllOfType.new('listing')
      all      = Checkpoint::Resource.all
      expect(resources).to contain_exactly(entity, wildcard, all)
    end

    it 'uses the same same wildcard with factory and instantiation' do
      entity   = Checkpoint::Resource.new(listing)
      wildcard = Checkpoint::Resource::AllOfType.new('listing')
      all      = Checkpoint::Resource.all
      expect(resources).to contain_exactly(entity, wildcard, all)
    end
  end

  describe 'conversion' do
    context 'when the entity does not respond to #to_resource' do
      let(:entity)   { double('entity', id: 'id') }
      let(:resource) { resolver.convert(entity) }

      it 'converts the entity to a default Resource' do
        expect(resource).to be_a Checkpoint::Resource
      end
    end

    context 'with a resource implementing #to_resource' do
      let(:entity)          { double('entity', to_resource: entity_resource) }
      let(:entity_resource) { double('entity', type: 'Entity', id: 'id') }
      let(:resource)        { resolver.convert(entity) }

      it 'lets the entity convert itself to a resource' do
        expect(resource).to eq entity_resource
      end
    end
  end
end
