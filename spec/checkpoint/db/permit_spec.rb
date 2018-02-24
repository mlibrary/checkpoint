# frozen_string_literal: true

require 'sequel_helper'
require 'checkpoint/db/permit'

RSpec.describe Checkpoint::DB::Permit, DB: true do
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
    subject(:permit) { described_class.from(agent, credential, resource) }

    it 'makes a Permit' do
      expect(permit).to be_a described_class
    end

    it 'uses the agent' do
      expect(permit.agent_type).to  eq 'user'
      expect(permit.agent_id).to    eq 'id'
      expect(permit.agent_token).to eq 'user:id'
    end

    it 'uses the credential' do
      expect(permit.credential_type).to  eq 'permission'
      expect(permit.credential_id).to    eq 'edit'
      expect(permit.credential_token).to eq 'permission:edit'
    end

    it 'uses the resource' do
      expect(permit.resource_type).to  eq 'resource'
      expect(permit.resource_id).to    eq '1'
      expect(permit.resource_token).to eq 'resource:1'
    end

    context 'without a zone supplied' do
      it 'uses the system zone' do
        expect(permit.zone_id).to eq 'system'
      end
    end

    context 'with a zone supplied' do
      subject(:permit) { described_class.from(agent, credential, resource, zone: 'zone') }

      it 'uses the zone' do
        expect(permit.zone_id).to eq 'zone'
      end
    end
  end
end
