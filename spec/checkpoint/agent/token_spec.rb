# frozen_string_literal: true

require 'checkpoint/agent/token'

module Checkpoint
  RSpec.describe Agent do
    subject(:agent) { described_class.new('a_type', 'an_id') }

    it 'returns its type' do
      expect(agent.type).to eq('a_type')
    end

    it 'returns its ID' do
      expect(agent.id).to eq('an_id')
    end

    describe '::from' do
      it 'converts an actor to an agent' do
        user = double('user', id: 'id')
        agent = described_class.from(user)
        expect(agent).to be_an Agent
      end
    end

    context 'when given non-string inputs' do
      subject(:agent) { described_class.new(Object, 1) }

      it 'converts the type to a string' do
        expect(agent.type).to be_a String
        expect(agent.type).to eq('Object')
      end

      it 'converts the id to a string' do
        expect(agent.id).to be_a String
        expect(agent.id).to eq('1')
      end
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

    describe "#eql?" do
      it 'considers agents as the same if type and id match' do
        agent1 = described_class.new('some-type', 'some-id')
        agent2 = described_class.new('some-type', 'some-id')
        expect(agent1).to eql(agent2)
      end

      it 'considers agents as different if type does not match' do
        agent1 = described_class.new('some-type', 'some-id')
        agent2 = described_class.new('other-type', 'some-id')
        expect(agent1).not_to eql(agent2)
      end

      it 'considers agents as different if id does not match' do
        agent1 = described_class.new('some-type', 'some-id')
        agent2 = described_class.new('some-type', 'other-id')
        expect(agent1).not_to eql(agent2)
      end
    end

    describe "#==" do
      it 'considers agents as the same if type and id match' do
        agent1 = described_class.new('some-type', 'some-id')
        agent2 = described_class.new('some-type', 'some-id')
        expect(agent1).to eq(agent2)
      end

      it 'considers agents as different if type does not match' do
        agent1 = described_class.new('some-type', 'some-id')
        agent2 = described_class.new('other-type', 'some-id')
        expect(agent1).not_to eq(agent2)
      end

      it 'considers agents as different if id does not match' do
        agent1 = described_class.new('some-type', 'some-id')
        agent2 = described_class.new('some-type', 'other-id')
        expect(agent1).not_to eq(agent2)
      end
    end
  end
end
