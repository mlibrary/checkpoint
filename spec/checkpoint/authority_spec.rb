# frozen_string_literal: true

require 'checkpoint/authority'

class FakePermits
  def for(subjects, credentials, _resources)
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

  let(:agent_resolver) { instance_double('Agent::Resolver', resolve: []) }
  let(:guest_resolver) { instance_double('Agent::Resolver', resolve: ['account-type:guest']) }

  let(:anna_resolver) do
    instance_double(
      'Agent::Resolver',
      resolve: ['user:anna', 'account-type:umich', 'affiliation:lib-staff']
    )
  end

  let(:katy_resolver) do
    instance_double(
      'Agent::Resolver',
      resolve: ['user:katy', 'account-type:umich', 'affiliation:faculty']
    )
  end

  let(:credential_resolver) { instance_double('Credential::Resolver', resolve: []) }
  let(:read_resolver)       { instance_double('Credential::Resolver', resolve: ['permission:read']) }
  let(:edit_resolver)       { instance_double('Credential::Resolver', resolve: ['permission:edit']) }

  let(:resource_resolver) { instance_double('Resource::Resolver', resolve: []) }

  let(:listing_resolver) do
    instance_double('Resource::Resolver', resolve: ['listing:17', 'type:listing'])
  end

  let(:authority) do
    Checkpoint::Authority.new(
      agent_resolver: agent_resolver,
      credential_resolver: credential_resolver,
      resource_resolver:  resource_resolver,
      permits: FakePermits.new
    )
  end

  subject(:permitted?) { authority.permits?(user, action, target) }

  context "for Anna (Library user)" do
    let(:user) { anna }
    let(:agent_resolver) { anna_resolver }
    let(:resource_resolver) { listing_resolver }

    context "when reading listing 17" do
      let(:action) { :read }
      let(:credential_resolver) { read_resolver }

      it "permits" do
        expect(permitted?).to be true
      end
    end

    context "when editing listing 17" do
      let(:action) { :edit }
      let(:credential_resolver) { edit_resolver }

      it "permits" do
        expect(permitted?).to be true
      end
    end
  end

  context "for Katy (Faculty member)" do
    let(:user) { katy }
    let(:agent_resolver) { katy_resolver }

    context "when reading listing 17" do
      let(:action) { :read }
      let(:credential_resolver) { read_resolver }

      it "permits" do
        expect(permitted?).to be true
      end
    end

    context "when editing listing 17" do
      let(:action) { :edit }
      let(:credential_resolver) { edit_resolver }

      it "does not permit" do
        expect(permitted?).to be false
      end
    end
  end

  context "for a guest user" do
    let(:user) { guest }
    let(:agent_resolver) { guest_resolver }

    context "when reading listing 17" do
      let(:action) { :read }
      let(:credential_resolver) { read_resolver }

      it "does not permit" do
        expect(permitted?).to eq false
      end
    end

    context "when editing listing 17" do
      let(:action) { :edit }
      let(:credential_resolver) { edit_resolver }

      it "does not permit" do
        expect(permitted?).to eq false
      end
    end
  end
end
