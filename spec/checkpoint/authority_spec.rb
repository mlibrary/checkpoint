# frozen_string_literal: true

require 'checkpoint/authority'

class FakeRepository
  def permits_for(subjects, credentials, resources)
    if credentials.include?('permission:edit') && subjects.include?('user:anna')
      [['user:anna', 'permission:edit', 'listing:17']]
    elsif credentials.include?('permission:read') && subjects.include?('account-type:umich')
      [[subjects.first, 'permission:read', 'listing:17']]
    else
      []
    end
  end
end

RSpec.describe Checkpoint::Authority do

  let(:anna)    { double('User', username: 'anna', known?: true) }
  let(:katy)    { double('User', username: 'katy', known?: true) }
  let(:guest)   { double('User', username: '<guest>', known?: false) }
  let(:listing) { double('Listing', id: 17, entity_type: 'listing') }
  let(:action)  { :read }
  let(:target)  { listing }

  let(:agent_resolver)    { instance_double('AgentResolver', resolve: []) }
  let(:anna_resolver)       { instance_double('AgentResolver', resolve: ['user:anna', 'account-type:umich', 'affiliation:lib-staff']) }
  let(:katy_resolver)       { instance_double('AgentResolver', resolve: ['user:katy', 'account-type:umich', 'affiliation:faculty']) }
  let(:guest_resolver)      { instance_double('AgentResolver', resolve: ['account-type:guest']) }

  let(:credential_resolver) { instance_double('CredentialResolver', resolve: []) }
  let(:read_resolver)       { instance_double('CredentialResolver', resolve: ['permission:read']) }
  let(:edit_resolver)       { instance_double('CredentialResolver', resolve: ['permission:edit']) }

  let(:resource_resolver)   { instance_double('ResourceResolver', resolve: []) }
  let(:listing_resolver)    { instance_double('ResourceResolver', resolve: ['listing:17', 'type:listing']) }

  subject(:authority) {
    Checkpoint::Authority.new(user, action, target).tap do |resolver|
      resolver.agent_resolver = agent_resolver
      resolver.credential_resolver = credential_resolver
      resolver.resource_resolver = resource_resolver
      resolver.repository = FakeRepository.new
    end
  }

  context "for Anna (Library user)" do
    let(:user) { anna }
    let(:agent_resolver)  { anna_resolver }
    let(:resource_resolver) { listing_resolver }

    context "when reading listing 17" do
      let(:action) { :read }
      let(:credential_resolver) { read_resolver }

      it "finds a permit" do
        expect(authority.any?).to be true
      end
    end

    context "when editing listing 17" do
      let(:action) { :edit }
      let(:credential_resolver) { edit_resolver }

      it "finds a permit" do
        expect(authority.any?).to be true
      end
    end
  end

  context "for Katy (Faculty member)" do
    let(:user) { katy }
    let(:agent_resolver) { katy_resolver }

    context "when reading listing 17" do
      let(:action) { :read }
      let(:credential_resolver) { read_resolver }

      it "finds a permit" do
        expect(authority.any?).to be true
      end
    end

    context "when editing listing 17" do
      let(:action) { :edit }
      let(:credential_resolver) { edit_resolver }

      it "does not find a permit" do
        expect(authority.any?).to be false
      end
    end
  end

  context "for a guest user" do
    let(:user) { guest }
    let(:agent_resolver) { guest_resolver }

    context "when reading listing 17" do
      let(:action) { :read }
      let(:credential_resolver) { read_resolver }

      it "does not find any permit" do
        expect(authority.any?).to eq false
      end
    end

    context "when editing listing 17" do
      let(:action) { :edit }
      let(:credential_resolver) { edit_resolver }

      it "does not find any permits" do
        expect(authority.any?).to eq false
      end
    end
  end

end
