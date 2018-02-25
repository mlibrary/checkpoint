# frozen_string_literal: true

require 'checkpoint/agent/conversion'

RSpec.describe Checkpoint::Agent::Conversion do
  it 'can be used as an instance' do
    user  = double('user', id: 'id')
    agent = described_class.new(user).call
    expect(agent.id).to eq 'id'
  end

  it 'can be used with the ::[] convenience method' do
    actor = double('user', id: 'id')
    agent = convert(actor)
    expect(agent.id).to eq 'id'
  end

  context 'with a generic user type' do
    let(:user)      { double('user', class: 'User', id: 'id') }
    subject(:agent) { convert(user) }

    it 'converts to an Agent' do
      expect(agent).to be_a Checkpoint::Agent
    end

    it 'converts with the user type' do
      expect(agent.type).to eq 'User'
    end

    it "converts with the id" do
      expect(user).to receive(:id)
      expect(agent.id).to eq 'id'
    end
  end

  context 'when the actor responds to #agent_id' do
    let(:user) { double('user', agent_id: 'id') }

    it 'calls #agent_id' do
      expect(user).to receive(:agent_id)
      convert(user)
    end

    it 'does not call #id' do
      expect(user).not_to receive(:id)
      convert(user)
    end

    it 'uses #agent_id' do
      agent = convert(user)
      expect(agent.id).to eq 'id'
    end
  end

  context 'when the actor responds to #agent_type' do
    let(:user) { double('user', agent_type: 'user', id: 'id') }

    it 'calls #agent_type' do
      expect(user).to receive(:agent_type)
      convert(user)
    end

    it 'uses the #agent_type' do
      agent = convert(user)
      expect(agent.type).to eq 'user'
    end

    it 'does not call #type' do
      expect(user).not_to receive(:type)
      convert(user)
    end
  end

  context 'when the actor responds to #to_agent' do
    let(:user)  { double('user', to_agent: agent) }
    let(:agent) { build('user', 'id') }

    it 'lets the actor convert itself to an agent' do
      converted = convert(user)
      expect(converted).to eq agent
    end

    it 'does not call #agent_type' do
      expect(user).not_to receive(:agent_type)
      convert(user)
    end

    it 'does not call #agent_id' do
      expect(user).not_to receive(:agent_id)
      convert(user)
    end

    it 'does not call #type' do
      expect(user).not_to receive(:type)
      convert(user)
    end

    it 'does not call #id' do
      expect(user).not_to receive(:id)
      convert(user)
    end
  end

  def convert(user)
    described_class[user]
  end

  def build(type, id)
    Checkpoint::Agent.new(type, id)
  end
end
