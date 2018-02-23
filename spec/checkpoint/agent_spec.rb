# frozen_string_literal: true

require 'checkpoint/agent'

module Checkpoint
  RSpec.describe Agent do
    subject(:agent) { described_class.new('a_type', 'an_id') }

    it 'returns its type' do
      expect(agent.type).to eq('a_type')
    end

    it 'returns its ID' do
      expect(agent.id).to eq('an_id')
    end

    it 'computes a token from its type and ID' do
      expect(agent.token).to eq('a_type:an_id')
    end

    it 'gives an agent URI' do
      expect(agent.uri).to eq('agent://a_type/an_id')
    end

    describe "#to_s" do
      it 'gives the token' do
        expect(agent.to_s).to eq('a_type:an_id')
      end
    end
  end
end
