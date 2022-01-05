# frozen_string_literal: true

require "checkpoint/authority"

module Checkpoint
  class FakeGrants
    def for(subjects, credentials, _resources)
      if credentials.include?("permission:edit") && subjects.include?("user:anna")
        [["user:anna", "permission:edit", "listing:17"]]
      elsif credentials.include?("permission:read") && subjects.include?("account-type:umich")
        [[subjects.first, "permission:read", "listing:17"]]
      else
        []
      end
    end
  end

  RSpec.describe Authority do
    let(:anna) { double("User", username: "anna", known?: true) }
    let(:katy) { double("User", username: "katy", known?: true) }
    let(:guest) { double("User", username: "<guest>", known?: false) }
    let(:listing) { double("Listing", id: 17, entity_type: "listing") }
    let(:action) { :read }
    let(:target) { listing }

    let(:agent_resolver) { instance_double(Agent::Resolver, expand: []) }
    let(:guest_resolver) { instance_double(Agent::Resolver, expand: ["account-type:guest"]) }

    let(:anna_resolver) do
      instance_double(
        "Agent::Resolver",
        expand: ["user:anna", "account-type:umich", "affiliation:lib-staff"]
      )
    end

    let(:katy_resolver) do
      instance_double(
        "Agent::Resolver",
        expand: ["user:katy", "account-type:umich", "affiliation:faculty"]
      )
    end

    let(:credential_resolver) { instance_double(Credential::Resolver, expand: []) }
    let(:read_resolver) { instance_double(Credential::Resolver, expand: ["permission:read"]) }
    let(:edit_resolver) { instance_double(Credential::Resolver, expand: ["permission:edit"]) }

    let(:resource_resolver) { instance_double(Resource::Resolver, expand: []) }

    let(:listing_resolver) do
      instance_double(Resource::Resolver, expand: ["listing:17", "type:listing"])
    end

    let(:repository) { FakeGrants.new }

    let(:authority) do
      Checkpoint::Authority.new(
        agent_resolver: agent_resolver,
        credential_resolver: credential_resolver,
        resource_resolver: resource_resolver,
        grants: repository
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

    describe "granting and revoking" do
      let(:agent) { instance_double(Agent, type: "agent", id: "aid", token: "agent:aid") }
      let(:credential) { instance_double(Credential, type: "cred", id: "cid", token: "cred:cid") }
      let(:resource) { instance_double(Resource, type: "entity", id: "eid", token: "en:eid") }
      let(:actor) { double("user") }
      let(:action) { double("action") }
      let(:entity) { double("entity") }
      let(:agent_resolver) { instance_double(Agent::Resolver, convert: agent) }
      let(:credential_resolver) { instance_double(Credential::Resolver, convert: credential) }
      let(:resource_resolver) { instance_double(Resource::Resolver, convert: resource) }

      describe "grant!" do
        it "saves a grant to the repository" do
          expect(repository).to receive(:grant!)
            .with(agent, credential, resource)
            .and_return(double("Grant"))

          authority.grant!(actor, action, entity)
        end
      end

      describe "revoke!" do
        it "deletes the grant from the repository" do
          expect(repository).to receive(:revoke!)
            .with(agent, credential, resource)
            .and_return(1)

          authority.revoke!(actor, action, entity)
        end
      end
    end

    describe "finding agents (who)" do
      # These specs are more integration-oriented, relying on default resolver
      # conversion/expansion to reduce the complexity of the harness.
      let(:authority) { described_class.new(grants: repository) }
      let(:repository) { instance_double(Grants, who: grants) }

      context "with a single user granted permission" do
        let(:grants) { [agent_grant] }
        let(:token) { agent_token }
        subject(:tokens) { authority.who(:read, double("entity")) }

        it "gives one token for the user" do
          expect(tokens).to contain_exactly(token)
        end
      end

      context "with multiple grants for a user" do
        let(:grants) { [agent_grant, agent_grant] }
        let(:token) { agent_token }
        subject(:tokens) { authority.who(:read, listing) }

        it "gives a single token for the user" do
          expect(tokens).to contain_exactly(token)
        end
      end

      context "with grants for two different users" do
        let(:grants) { [agent_grant(id: "one"), agent_grant(id: "two")] }
        let(:one) { agent_token(id: "one") }
        let(:two) { agent_token(id: "two") }
        subject(:tokens) { authority.who(:read, listing) }

        it "gives a token for each user" do
          expect(tokens).to contain_exactly(one, two)
        end
      end
    end

    describe "finding resources (which)" do
      # These specs are more integration-oriented, relying on default resolver
      # conversion/expansion to reduce the complexity of the harness.
      let(:authority) { described_class.new(grants: repository) }
      let(:repository) { instance_double(Grants, which: grants) }

      context "with a single resource granted" do
        let(:grants) { [resource_grant] }
        let(:token) { resource_token }
        subject(:tokens) { authority.which(double("user"), :read) }

        it "gives one token for the resource" do
          expect(tokens).to contain_exactly(token)
        end
      end

      context "with multiple grants for a resource" do
        let(:grants) { [resource_grant, resource_grant] }
        let(:token) { resource_token }
        subject(:tokens) { authority.which(double("user"), :read) }

        it "gives a single token for the resource" do
          expect(tokens).to contain_exactly(token)
        end
      end

      context "with grants for two different users" do
        let(:grants) { [resource_grant(id: "one"), resource_grant(id: "two")] }
        let(:one) { resource_token(id: "one") }
        let(:two) { resource_token(id: "two") }
        subject(:tokens) { authority.which(double("user"), :read) }

        it "gives a token for each user" do
          expect(tokens).to contain_exactly(one, two)
        end
      end
    end

    describe "finding credentials (what)" do
      # These specs are more integration-oriented, relying on default resolver
      # conversion/expansion to reduce the complexity of the harness.
      let(:authority) { described_class.new(grants: repository) }
      let(:repository) { instance_double(Grants, what: grants) }

      context "with a single credential granted" do
        let(:grants) { [credential_grant] }
        let(:token) { credential_token }
        subject(:tokens) { authority.what(double("user"), double("entity")) }

        it "gives one token for the credential" do
          expect(tokens).to contain_exactly(token)
        end
      end

      context "with multiple grants of the same credential" do
        let(:grants) { [credential_grant, credential_grant] }
        let(:token) { credential_token }
        subject(:tokens) { authority.what(double("user"), double("entity")) }

        it "gives a single token for the credential" do
          expect(tokens).to contain_exactly(token)
        end
      end

      context "with grants for two different users" do
        let(:grants) { [credential_grant(id: "read"), credential_grant(id: "edit")] }
        let(:one) { credential_token(id: "read") }
        let(:two) { credential_token(id: "edit") }
        subject(:tokens) { authority.what(double("user"), double("entity")) }

        it "gives a token for each credential" do
          expect(tokens).to contain_exactly(one, two)
        end
      end
    end

    def agent_grant(type: "user", id: "id")
      instance_double(DB::Grant, agent_type: type, agent_id: id)
    end

    def agent_token(type: "user", id: "id")
      Agent::Token.new(type, id)
    end

    def credential_grant(type: "permission", id: "read")
      instance_double(DB::Grant, credential_type: type, credential_id: id)
    end

    def credential_token(type: "permission", id: "read")
      Credential::Token.new(type, id)
    end

    def resource_grant(type: "entity", id: "id")
      instance_double(DB::Grant, resource_type: type, resource_id: id)
    end

    def resource_token(type: "entity", id: "id")
      Resource::Token.new(type, id)
    end
  end
end
