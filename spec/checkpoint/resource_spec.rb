# frozen_string_literal: true

require 'checkpoint/resource'

FakeEntity = Struct.new(:id)

RSpec.describe Checkpoint::Resource do
  describe '#initialize' do
    it 'stores the entity' do
      entity   = double('entity', id: 'id')
      resource = described_class.new(entity)
      expect(resource.entity).to eq entity
    end
  end

  context 'with an entity that has no usable identifier' do
    it 'raises an error' do
      expect do
        entity = double('entity')
        described_class.new(entity).id
      end.to raise_error Checkpoint::NoIdentifierError
    end
  end

  describe '#token' do
    let(:entity)    { double('entity', class: 'Entity', id: 'id') }
    subject(:token) { described_class.new(entity).token }

    it 'gives a token' do
      expect(token).to be_an described_class::Token
    end

    it 'has the correct type' do
      expect(token.type).to eq('Entity')
    end

    it 'has the correct id' do
      expect(token.id).to eq('id')
    end
  end

  describe '::from' do
    it 'converts an entity to a resource' do
      entity   = double('entity', id: 'id')
      resource = described_class.from(entity)
      expect(resource).to be_a Checkpoint::Resource
    end

    context 'with a resource implementing #to_resource' do
      let(:entity)          { double('entity', to_resource: entity_resource) }
      let(:entity_resource) { double('entity', type: 'Entity', id: 'id') }
      let(:resource)        { described_class.from(entity) }

      it 'lets the entity convert itself to a resource' do
        expect(resource).to eq entity_resource
      end

      it 'does not ask the entity its #resource_type' do
        expect(entity).not_to receive(:resource_type)
        resource.type
      end

      it 'does not ask the entity its #resource_id' do
        expect(entity).not_to receive(:resource_id)
        resource.id
      end

      it 'does not ask the entity its #id' do
        expect(entity).not_to receive(:id)
        resource.id
      end
    end
  end

  describe '.all' do
    let(:resource) { described_class.all }

    it 'gives a Resource' do
      expect(resource).to be_a Checkpoint::Resource
    end

    it 'gives the Resource with the special ALL type' do
      expect(resource.type).to eq Checkpoint::Resource::ALL
    end

    it 'gives the Resource with the special ALL id' do
      expect(resource.id).to eq Checkpoint::Resource::ALL
    end
  end

  describe '#all_of_type' do
    let(:entity)   { double('entity', class: 'Entity', id: 'id') }
    let(:resource) { described_class.new(entity) }
    let(:wildcard) { resource.all_of_type }

    it 'gives a Resource' do
      expect(wildcard).to be_a Checkpoint::Resource
    end

    it 'gives a Resource with the same type' do
      expect(wildcard.type).to eq 'Entity'
    end

    it 'gives a Resource with the special ALL id' do
      expect(wildcard.id).to eq Checkpoint::Resource::ALL
    end
  end

  # @botimer - 2018-02-26: I'm of two minds on this kind of test. There is an
  # argument that including some kind of realistic example (say, a Document
  # type) helps clarify expected usage. There is also an argument that this is
  # incidental detail that distracts from the specific behavior that we are
  # testing here. This has been changed from an application-oriented example
  # (Listing:12) to a generic example (Model:id) to compare.
  context 'with a generic entity object (like a default Rails model)' do
    let(:model)        { double('model', class: Object, id: 'id') }
    subject(:resource) { described_class.new(model) }

    it 'converts to a Resource' do
      expect(resource).to be_a Checkpoint::Resource
    end

    it 'reports the type as the classname as a string' do
      expect(resource.type).to eq 'Object'
    end

    it 'uses the #id property' do
      expect(model).to receive(:id)
      expect(resource.id).to eq 'id'
    end
  end

  # To compare with the generic example above, this is specific. It supplies
  # application-oriented names and values that are expected. This could be
  # considered incidental detail, though it does provide some usage context and
  # fuzz test the implementation to a slight degree.
  context 'with a resource implementing #resource_type' do
    let(:newspaper)    { double('Newspaper', id: 8, resource_type: Object) }
    subject(:resource) { described_class.new(newspaper) }

    it 'uses the #resource_type as a string' do
      expect(resource.type).to eq 'Object'
    end
  end

  context 'with an entity implementing #resource_id' do
    let(:entity)   { double('entity', resource_id: 'id') }
    let(:resource) { described_class.new(entity) }

    it 'uses the #resource_id' do
      expect(resource.id).to eq 'id'
    end

    it 'calls #resource_id' do
      expect(entity).to receive(:resource_id)
      resource.id
    end

    it 'does not call #id' do
      expect(entity).not_to receive(:id)
      resource.id
    end

    it 'coerces the id to a string' do
      entity   = double('entity', resource_id: 1)
      resource = described_class.new(entity)
      expect(resource.id).to eq '1'
    end
  end

  describe '#eql?' do
    it 'is true for two resources wrapping the same object' do
      entity    = double('entity', class: 'Entity', id: 'id')
      resource1 = described_class.new(entity)
      resource2 = described_class.new(entity)
      expect(resource1).to eql(resource2)
    end

    it 'uses eql? to compare the entities' do
      entity1   = double('entity', class: 'Entity', id: 'id')
      entity2   = double('entity', class: 'Entity', id: 'id')
      resource1 = described_class.new(entity1)
      resource2 = described_class.new(entity2)

      allow(entity1).to receive(:eql?).with(entity2).and_return(true)
      expect(resource1).to eql(resource2)
    end

    it 'is false for two resources wrapping unequal (!eql?) objects' do
      entity1   = double('entity', class: 'Entity', id: 'id')
      entity2   = double('other', class: 'Other', id: 'id')
      resource1 = described_class.new(entity1)
      resource2 = described_class.new(entity2)
      expect(resource1).not_to eql(resource2)
    end
  end

  describe '#==' do
    it 'is true for two resources wrapping the same object' do
      entity    = double('entity', class: 'Entity', id: 'id')
      resource1 = described_class.new(entity)
      resource2 = described_class.new(entity)
      expect(resource1).to eq(resource2)
    end

    it 'uses == to compare the entities' do
      entity1   = double('entity', class: 'Entity', id: 'id')
      entity2   = double('entity', class: 'Entity', id: 'id')
      resource1 = described_class.new(entity1)
      resource2 = described_class.new(entity2)

      allow(entity1).to receive(:==).with(entity2).and_return(true)
      expect(resource1).to eq(resource2)
    end

    it 'is false for two resources wrapping unequal (!=) objects' do
      entity1   = double('entity', class: 'Entity', id: 'id')
      entity2   = double('other', class: 'Other', id: 'id')
      resource1 = described_class.new(entity1)
      resource2 = described_class.new(entity2)

      expect(resource1).not_to eq(resource2)
    end
  end
end
