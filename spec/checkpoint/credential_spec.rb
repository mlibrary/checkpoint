# frozen_string_literal: true

require 'checkpoint/credential'

module Checkpoint
  RSpec.describe Credential do
    subject(:credential) { described_class.new('a_type', 'an_id') }

    it 'returns its type' do
      expect(credential.type).to eq('a_type')
    end

    it 'returns its ID' do
      expect(credential.id).to eq('an_id')
    end

    it 'computes a token from its type and ID' do
      expect(credential.token).to eq('a_type:an_id')
    end

    describe "#to_s" do
      it 'gives a credential URI' do
        expect(credential.to_s).to eq('credential://a_type/an_id')
      end
    end
  end
end
