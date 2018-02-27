# frozen_string_literal: true

require 'checkpoint/resource/all_of_type'

RSpec.describe Checkpoint::Resource::AllOfType do
  describe '#initialize' do
    it 'stores the type' do
      resource = described_class.new('type')
      expect(resource.type).to eq 'type'
    end
  end

  describe '::from' do
    context 'with a generic entity' do
      let(:entity)   { double('entity', class: 'Entity', id: 'id') }
      let(:resource) { described_class.from(entity) }

      it 'uses the type from the entity' do
        expect(resource.type).to eq 'Entity'
      end

      it 'uses the ALL constant as the id' do
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

      it 'uses the type from the entity-provided resource' do
        expect(resource.type).to eq 'type'
      end

      it 'uses the ALL constant as the id' do
        expect(resource.id).to eq Checkpoint::Resource::ALL
      end
    end

    context 'with an entity implementing #resource_type' do
      let(:entity)   { double('entity', resource_type: 'type', id: 'id') }
      let(:resource) { described_class.from(entity) }

      it 'uses the type from the entity' do
        expect(resource.type).to eq 'type'
      end

      it 'uses the ALL constant as the id' do
        expect(resource.id).to eq Checkpoint::Resource::ALL
      end
    end
  end

  describe '#eql?' do
    it 'is true for two instances with the same type' do
      resource = described_class.new('type')
      other    = described_class.new('type')
      expect(resource).to eql other
    end

    it 'is true for a true any resource with the same type' do
      entity   = double('entity', resource_type: 'type', id: 'id')
      other    = Checkpoint::Resource.new(entity)
      resource = described_class.new('type')

      expect(resource).to eql other
    end
  end

  describe '#==' do
    it 'is true for two instances with the same type' do
      resource = described_class.new('type')
      other    = described_class.new('type')
      expect(resource).to eq other
    end
  end
end
