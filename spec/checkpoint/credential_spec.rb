# frozen_string_literal: true

require 'checkpoint/credential'

RSpec.describe Checkpoint::Credential do
  describe '#new' do
    it 'has the generic credential type' do
      credential = described_class.new(name: 'name')
      expect(credential.type).to eq 'credential'
    end

    it 'stores the name' do
      credential = described_class.new(name: 'name')
      expect(credential.name).to eq 'name'
    end

    it 'coerces the name to a string' do
      credential = described_class.new(name: :name)
      expect(credential.name).to eq 'name'
    end
  end

  describe '#eql?' do
    it 'gives true if the type and name match' do
      credential = described_class.new(name: 'name')
      other      = described_class.new(name: 'name')
      expect(credential).to eql(other)
    end

    it 'gives false if the name does not match' do
      credential = described_class.new(name: 'name')
      other      = described_class.new(name: 'other')
      expect(credential).not_to eql(other)
    end
  end
end
