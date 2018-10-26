# frozen_string_literal: true

require 'checkpoint/agent/resolver'

RSpec.describe Checkpoint::Agent::Resolver do
  let(:resolver) { described_class.new }

  describe 'expansion' do
    let(:user)       { double('user', id: 'id') }
    subject(:agents) { resolver.expand(user) }

    it 'expands an actor into an agent' do
      expect(agents).to all be_a Checkpoint::Agent
    end

    it 'expands an actor to a single agent' do
      expect(agents.size).to eq 1
    end
  end

  describe 'conversion' do
    context 'when the actor does not respond to #to_agent' do
      let(:user)  { double('user', id: 'id') }
      let(:agent) { resolver.convert(user) }

      it 'converts the actor to a default Agent' do
        expect(agent).to be_a Checkpoint::Agent
      end
    end

    context 'when the actor responds to #to_agent' do
      let(:user)       { double('user', to_agent: user_agent) }
      let(:user_agent) { double('agent', type: 'User', id: 'id') }
      let(:agent)      { resolver.convert(user) }

      it 'lets the actor convert itself to an agent' do
        expect(agent).to eq user_agent
      end
    end
  end

end
