# frozen_string_literal: true

require 'checkpoint/agent'

RSpec.describe Checkpoint::Agent do
  describe '#new' do
    it 'stores the actor' do
      user  = double('user', id: 'id')
      agent = described_class.new(user)
      expect(agent.actor).to eq user
    end
  end

  context 'with an actor that has no usable identifier' do
    it 'raises an error' do
      expect do
        actor = double('actor')
        described_class.new(actor).id
      end.to raise_error Checkpoint::NoIdentifierError
    end
  end

  describe '#token' do
    let(:user)      { double('user', class: 'User', id: 'id') }
    subject(:token) { described_class.new(user).token }

    it 'gives a token' do
      expect(token).to be_an described_class::Token
    end

    it 'has the correct type' do
      expect(token.type).to eq('User')
    end

    it 'has the correct id' do
      expect(token.id).to eq('id')
    end
  end

  context 'with a generic User object' do
    let(:user)      { double('user', class: 'User', id: 'id') }
    subject(:agent) { described_class.new(user) }

    it 'reports the type as User' do
      expect(agent.type).to eq 'User'
    end

    it 'uses the #id property' do
      expect(user).to receive(:id)
      expect(agent.id).to eq 'id'
    end
  end

  context 'when the actor responds to #agent_id' do
    let(:user)  { double('user', agent_id: 'id') }
    let(:agent) { described_class.new(user) }

    it 'calls #agent_id' do
      expect(user).to receive(:agent_id)
      agent.id
    end

    it 'uses #agent_id' do
      expect(agent.id).to eq 'id'
    end

    it 'does not call #id' do
      expect(user).not_to receive(:id)
      agent.id
    end

    it 'coerces the id to a string' do
      user  = double('user', agent_id: 1)
      agent = described_class.new(user)
      expect(agent.id).to eq '1'
    end
  end

  context 'when the actor responds to #agent_type' do
    let(:user)  { double('user', agent_type: 'user', id: 'id') }
    let(:agent) { described_class.new(user) }

    it 'uses the #agent_type' do
      expect(agent.type).to eq 'user'
    end

    it 'calls #agent_type' do
      expect(user).to receive(:agent_type)
      agent.type
    end

    it 'coerces the type to a string' do
      user  = double('user', agent_type: Object, id: 1)
      agent = described_class.new(user)
      expect(agent.type).to eq 'Object'
    end
  end

  describe '#eql?' do
    it 'is true for two agents wrapping the same object' do
      actor  = double('actor', class: 'User', id: 'id')
      agent1 = described_class.new(actor)
      agent2 = described_class.new(actor)
      expect(agent1).to eql(agent2)
    end

    it 'uses eql? to compare the entities' do
      actor1 = double('actor', class: 'User', id: 'id')
      actor2 = double('actor', class: 'User', id: 'id')
      agent1 = described_class.new(actor1)
      agent2 = described_class.new(actor2)

      allow(actor1).to receive(:eql?).with(actor2).and_return(true)
      expect(agent1).to eql(agent2)
    end

    it 'is false for two agents wrapping unequal (!eql?) objects' do
      actor1 = double('actor', class: 'User', id: 'id')
      actor2 = double('other', class: 'Other', id: 'id')
      agent1 = described_class.new(actor1)
      agent2 = described_class.new(actor2)
      expect(agent1).not_to eql(agent2)
    end
  end

  describe '#==' do
    it 'is true for two agents wrapping the same object' do
      actor  = double('actor', class: 'User', id: 'id')
      agent1 = described_class.new(actor)
      agent2 = described_class.new(actor)
      expect(agent1).to eq(agent2)
    end

    it 'uses == to compare the entities' do
      actor1 = double('actor', class: 'User', id: 'id')
      actor2 = double('actor', class: 'User', id: 'id')
      agent1 = described_class.new(actor1)
      agent2 = described_class.new(actor2)

      allow(actor1).to receive(:==).with(actor2).and_return(true)
      expect(agent1).to eq(agent2)
    end

    it 'is false for two agents wrapping unequal (!=) objects' do
      actor1 = double('actor', class: 'User', id: 'id')
      actor2 = double('other', class: 'Other', id: 'id')
      agent1 = described_class.new(actor1)
      agent2 = described_class.new(actor2)

      expect(agent1).not_to eq(agent2)
    end
  end
end
