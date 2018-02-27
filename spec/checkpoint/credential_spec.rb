# frozen_string_literal: true

require 'checkpoint/credential'

RSpec.describe Checkpoint::Credential do
  describe '#new' do
    it 'stores the name' do
      credential = described_class.new(:FIXME, :FIXME, name: 'action')
      expect(credential.name).to eq 'action'
    end

    it 'coerces the name to a string' do
      credential = described_class.new(:FIXME, :FIXME, name: :action)
      expect(credential.name).to eq 'action'
    end
  end
end
