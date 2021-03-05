# frozen_string_literal: true

RSpec.describe Checkpoint::DB::Query::ACR do
  let(:agents) { [double("agent", token: "agent:aid")] }
  let(:credentials) { [double("perm", token: "perm:pid")] }
  let(:resources) { [double("entity", token: "entity:eid")] }
  subject(:query) { described_class.new(agents, credentials, resources) }

  describe "conditions" do
    it "include placeholders for agent tokens" do
      expect(query.conditions).to include(agent_token: [:$at_0])
    end

    it "include placeholders for credential tokens" do
      expect(query.conditions).to include(credential_token: [:$ct_0])
    end

    it "include placeholders for resource tokens" do
      expect(query.conditions).to include(resource_token: [:$rt_0])
    end
  end

  describe "parameters" do
    it "include agent tokens" do
      expect(query.parameters).to include(at_0: "agent:aid")
    end

    it "include credential tokens" do
      expect(query.parameters).to include(ct_0: "perm:pid")
    end

    it "include resource tokens" do
      expect(query.parameters).to include(rt_0: "entity:eid")
    end
  end
end
