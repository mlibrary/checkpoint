# frozen_string_literal: true

require 'checkpoint/resource'
require 'checkpoint/resource_resolver'

RSpec.describe Checkpoint::ResourceResolver do
  let(:resolver)  { described_class.new }

  context 'with a listing' do
    let(:listing)       { double('Listing', id: 12, type: 'listing') }
    subject(:resources) { resolver.resolve(listing) }

    it 'resolves to a set of Resources' do
      expect(resources).to all be_a Checkpoint::Resource
    end

    it 'resolves to an entity resource' do
      resource = build('listing', '12')
      expect(resources).to include(resource)
    end

    it 'resolves to a type resource' do
      resource = build('listing', all_ids)
      expect(resources).to include(resource)
    end

    it 'resolves to only the entity and type resources' do
      entity = build('listing', '12')
      type   = build('listing', all_ids)
      expect(resources).to contain_exactly(entity, type)
    end
  end

  context 'with a different listing' do
    let(:listing)       { double('Listing', id: 13, type: 'listing') }
    subject(:resources) { resolver.resolve(listing) }

    it 'resolves to an entity resource' do
      resource = build('listing', '13')
      expect(resources).to include(resource)
    end
  end

  context 'with a resource implementing #resource_type' do
    let(:newspaper)     { double('Newspaper', id: 8, resource_type: 'newspaper') }
    subject(:resources) { resolver.resolve(newspaper) }

    it 'resolves to the correct entity resource' do
      resource = build('newspaper', '8')
      expect(resources).to include(resource)
    end

    it 'resolves to correct type resource' do
      resource = build('newspaper', all_ids)
      expect(resources).to include(resource)
    end
  end

  context 'with a resource implementing #to_resource' do
    let(:entity)   { double('entity', to_resource: resource) }
    let(:resource) { build('entity', 'id') }
    let(:wildcard) { build('entity', all_ids) }
    subject(:resources) { resolver.resolve(entity) }

    it 'calls #to_resource on the entity' do
      expect(entity).to receive(:to_resource)
      resources
    end

    it 'lets the entity convert itself to a resource' do
      expect(resources).to include(resource)
    end

    it 'resolves to a wildcard of the type given by #to_resource' do
      expect(resources).to include(wildcard)
    end

    it 'does not ask the entity its #type' do
      expect(entity).not_to receive(:type)
      resources
    end

    it 'does not ask the entity its #resource_type' do
      expect(entity).not_to receive(:resource_type)
      resources
    end
  end

  context 'with an entity implementing #resource_id' do
    let(:entity) { double('entity', type: 'entity', resource_id: 'id') }
    subject(:resources) { resolver.resolve(entity) }

    it 'does not call #id' do
      expect(entity).not_to receive(:id)
      resources
    end

    it 'calls #resource_id' do
      expect(entity).to receive(:resource_id)
      resources
    end
  end

  context 'with an entity not implementing any type hinting' do
    before(:all) { FakeEntity = Struct.new(:id) }
    let(:entity) { FakeEntity.new(1) }
    let(:resource)      { build('FakeEntity', '1') }
    let(:wildcard)      { build('FakeEntity', all_ids) }
    subject(:resources) { resolver.resolve(entity) }

    it 'uses the entity class for the type' do
      expect(resources).to include(resource, wildcard)
    end
  end

  def build(type, id)
    Checkpoint::Resource.new(type, id)
  end

  def all_ids
    Checkpoint::Resource::ALL
  end
end
