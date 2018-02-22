# frozen_string_literal: true

require 'checkpoint/agent_resolver'

class FakeDirectory
  def attributes_for(user)
    case user.username
    when 'bill'
      { account_type: 'umich', affiliations: ['faculty'] }
    when 'bob'
      { account_type: 'umich', affiliations: ['lib-staff'] }
    when 'jane'
      { account_type: 'umich', affiliations: ['faculty', 'lib-staff'] }
    else
      {}
    end
  end
end

RSpec.describe Checkpoint::AgentResolver do
  context "with a known user" do
    let(:bill)  { double('User', username: 'bill') }
    let(:bob)   { double('User', username: 'bob') }
    let(:jane)  { double('User', username: 'jane') }
    let(:guest) { double('User', username: '<guest>') }
    let(:directory)    { FakeDirectory.new }
    subject(:resolver) { described_class.new(directory: directory) }

    it "resolves User `bill`'s tokens" do
      expect(resolver.resolve(bill)).to include(
        'account-type:umich', 'user:bill', 'affiliation:faculty'
      )
    end

    it "resolves User `bob`'s tokens" do
      expect(resolver.resolve(bob)).to include(
        'account-type:umich', 'user:bob', 'affiliation:lib-staff'
      )
    end

    it "resolves User `jane`'s tokens" do
      expect(resolver.resolve(jane)).to include(
        'account-type:umich', 'user:jane', 'affiliation:lib-staff', 'affiliation:faculty'
      )
    end

    it "resolves guest user's tokens" do
      expect(resolver.resolve(guest)).to include('account-type:guest', 'user:<guest>')
    end
  end
end
