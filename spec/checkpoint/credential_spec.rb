# frozen_string_literal: true

require 'checkpoint/credential'

RSpec.describe Checkpoint::Credential do
  describe '#new' do
    it 'has the generic credential type' do
      credential = described_class.new('name')
      expect(credential.type).to eq 'credential'
    end

    it 'stores the name' do
      credential = described_class.new('name')
      expect(credential.name).to eq 'name'
    end

    it 'coerces the name to a string' do
      credential = described_class.new(:name)
      expect(credential.name).to eq 'name'
    end
  end

  # Note that this is for consistency in interface with Agent and Resource,
  # even though name is more intuitive for a Credential.
  it 'aliases id to name' do
    credential = described_class.new('name')
    expect(credential.id).to eq 'name'
  end

  it 'returns itself when asked to convert to a credential' do
    credential = described_class.new('name')
    expect(credential.to_credential).to eq credential
  end

  describe '#granted_by' do
    it 'returns the credential itself in an array' do
      credential = described_class.new('name')
      expect(credential.granted_by).to eq([credential])
    end
  end

  describe '#token' do
    let(:credential) { described_class.new('name') }
    let(:token)      { credential.token }

    it 'gives a Token' do
      expect(token).to be_a Checkpoint::Credential::Token
    end

    it 'has name as the id' do
      expect(token.id).to eq 'name'
    end
  end

  describe '#eql?' do
    it 'gives true if the type and name match' do
      credential = described_class.new('name')
      other      = described_class.new('name')
      expect(credential).to eql(other)
    end

    it 'gives false if the name does not match' do
      credential = described_class.new('name')
      other      = described_class.new('other')
      expect(credential).not_to eql(other)
    end
  end

  describe '#==' do
    it 'gives true if the type and name match' do
      credential = described_class.new('name')
      other      = described_class.new('name')
      expect(credential).to eq(other)
    end

    it 'gives false if the name does not match' do
      credential = described_class.new('name')
      other      = described_class.new('other')
      expect(credential).not_to eq(other)
    end
  end
end
