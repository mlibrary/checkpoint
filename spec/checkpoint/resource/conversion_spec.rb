# frozen_string_literal: true

require 'checkpoint/resource/conversion'

FakeEntity = Struct.new(:id)

RSpec.describe Checkpoint::Resource::Conversion do
  it 'can be used as an instance' do
    entity   = double('entity', id: 'id')
    resource = described_class.new(entity).call
    expect(resource.id).to eq 'id'
  end

  it 'can be used with the ::[] convenience method' do
    entity   = double('entity', id: 'id')
    resource = convert(entity)
    expect(resource.id).to eq 'id'
  end

  context 'with a listing' do
    let(:listing) { double('Listing', id: 12, resource_type: 'listing') }

    it 'converts to a Resource' do
      resource = convert(listing)
      expect(resource).to be_a Checkpoint::Resource
    end

    it 'converts to an entity resource' do
      resource = build('listing', '12')
      converted = convert(listing)
      expect(converted).to eq resource
    end
  end

  context 'with a different listing' do
    let(:listing) { double('Listing', id: 13, resource_type: 'listing') }

    it 'converts to an entity resource' do
      resource  = build('listing', '13')
      converted = convert(listing)
      expect(converted).to eq resource
    end
  end

  context 'with a resource implementing #resource_type' do
    let(:newspaper) { double('Newspaper', id: 8, resource_type: 'newspaper') }

    it 'converts to the correct entity resource' do
      resource  = build('newspaper', '8')
      converted = convert(newspaper)
      expect(converted).to eq resource
    end
  end

  context 'with a resource implementing #to_resource' do
    let(:entity)   { double('entity', to_resource: resource) }
    let(:resource) { build('entity', 'id') }

    it 'lets the entity convert itself to a resource' do
      converted = convert(entity)
      expect(converted).to eq resource
    end

    it 'does not ask the entity its #resource_type' do
      expect(entity).not_to receive(:resource_type)
      convert(entity)
    end
  end

  context 'with an entity implementing #resource_id' do
    let(:entity) { double('entity', resource_id: 'id') }

    it 'calls #resource_id' do
      expect(entity).to receive(:resource_id)
      convert(entity)
    end

    it 'does not call #id' do
      expect(entity).not_to receive(:id)
      convert(entity)
    end
  end

  context 'with an entity not implementing any type hinting' do
    let(:entity) { FakeEntity.new(1) }
    let(:resource)     { build('FakeEntity', '1') }
    subject(:resource) { convert(entity) }

    it 'uses the entity class for the type' do
      expect(resource).to eq resource
    end
  end

  def convert(entity)
    described_class[entity]
  end

  def build(type, id)
    Checkpoint::Resource.new(type, id)
  end
end

RSpec.describe Checkpoint::Resource::WildcardConversion do
  it 'extends the entity conversion' do
    expect(described_class).to be < Checkpoint::Resource::Conversion
  end

  context 'with a listing' do
    let(:listing) { double('Listing', id: 12, resource_type: 'listing') }

    it 'converts to a type resource' do
      resource  = build('listing', all_ids)
      converted = convert(listing)
      expect(converted).to eq resource
    end
  end

  context 'with an entity not implementing any type hinting' do
    let(:entity) { FakeEntity.new(1) }
    let(:wildcard)     { build('FakeEntity', all_ids) }
    subject(:resource) { convert(entity) }

    it 'uses the entity class for the type' do
      expect(resource).to eq wildcard
    end
  end

  context 'with a resource implementing #to_resource' do
    let(:entity)   { double('entity', to_resource: wildcard) }
    let(:wildcard) { build('entity', all_ids) }
    let(:resource) { convert(entity) }

    it 'converts to a wildcard of the type given by #to_resource' do
      expect(resource).to eq wildcard
    end
  end

  context 'with a resource implementing #resource_type' do
    let(:newspaper) { double('Newspaper', id: 8, resource_type: 'newspaper') }

    it 'converts to correct type resource' do
      resource = build('newspaper', all_ids)
      converted = convert(newspaper)
      expect(converted).to eq resource
    end
  end

  def convert(entity)
    described_class[entity]
  end

  def build(type, id)
    Checkpoint::Resource.new(type, id)
  end

  def all_ids
    Checkpoint::Resource::ALL
  end
end
