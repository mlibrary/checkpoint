# frozen_string_literal: true

require 'sequel_helper'
require 'checkpoint/db/grant'

RSpec.describe Checkpoint::DB::Grant, DB: true do
  Grant = Checkpoint::DB::Grant

  let(:agent) do
    double('agent', type: 'user', id: 'id', token: 'user:id')
  end

  let(:credential) do
    double('credential', type: 'permission', id: 'edit', token: 'permission:edit')
  end

  let(:resource) do
    double('resource', type: 'resource', id: '1', token: 'resource:1')
  end

  it 'has a default zone' do
    expect(described_class.default_zone).not_to be_empty
  end

  describe '.from' do
    subject(:grant) { described_class.from(agent, credential, resource) }

    it 'makes a Grant' do
      expect(grant).to be_a described_class
    end

    it 'uses the agent' do
      expect(grant.agent_type).to  eq 'user'
      expect(grant.agent_id).to    eq 'id'
      expect(grant.agent_token).to eq 'user:id'
    end

    it 'uses the credential' do
      expect(grant.credential_type).to  eq 'permission'
      expect(grant.credential_id).to    eq 'edit'
      expect(grant.credential_token).to eq 'permission:edit'
    end

    it 'uses the resource' do
      expect(grant.resource_type).to  eq 'resource'
      expect(grant.resource_id).to    eq '1'
      expect(grant.resource_token).to eq 'resource:1'
    end

    context 'without a zone supplied' do
      it 'uses the default, system zone' do
        expect(grant.zone_id).to eq Grant.default_zone
      end
    end

    context 'with a zone supplied' do
      subject(:grant) { described_class.from(agent, credential, resource, zone: 'zone') }

      it 'uses the zone' do
        expect(grant.zone_id).to eq 'zone'
      end
    end
  end
end
