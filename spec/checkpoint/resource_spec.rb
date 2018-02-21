# frozen_string_literal: true

require 'checkpoint/resource'

module Checkpoint
  RSpec.describe Resource do
    subject(:resource) { described_class.new('a_type', 'an_id') }

    it 'returns its type' do
      expect(resource.type).to eq('a_type')
    end

    it 'returns its ID' do
      expect(resource.id).to eq('an_id')
    end

    it 'computes a token from its type and ID' do
      expect(resource.token).to eq('a_type:an_id')
    end

    describe "#to_s" do
      it 'gives an resource URI' do
        expect(resource.to_s).to eq('resource://a_type/an_id')
      end
    end
  end
end

