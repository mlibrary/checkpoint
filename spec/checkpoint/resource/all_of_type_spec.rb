# frozen_string_literal: true

require 'checkpoint/resource/all_of_type'

RSpec.describe Checkpoint::Resource::AllOfType do
  describe '#initialize' do
    it 'stores the type' do
      resource = described_class.new('type')
      expect(resource.type).to eq 'type'
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
