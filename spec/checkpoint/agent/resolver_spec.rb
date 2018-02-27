# frozen_string_literal: true

require 'checkpoint/agent/resolver'

RSpec.describe Checkpoint::Agent::Resolver do
  let(:user)       { double('user', id: 'id') }
  let(:resolver)   { described_class.new }
  subject(:agents) { resolver.resolve(user) }

  it 'resolves an actor into an agent' do
    expect(agents).to all be_a Checkpoint::Agent
  end

  it 'resolves an actor to a single agent' do
    expect(agents.size).to eq 1
  end
end
