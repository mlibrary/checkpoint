# frozen_string_literal: true

require 'sequel_helper'

require 'checkpoint/agent/token'
require 'checkpoint/credential/token'
require 'checkpoint/resource/token'
require 'checkpoint/permits'

RSpec.describe Checkpoint::Permits, DB: true do
  subject(:permits) { described_class.new }

  context 'when storing one permit in the default zone' do
    let(:permit)  { new_permit(agent, credential, resource) }
    before(:each) { permit.save }

    context 'and searching for it' do
      describe '#for' do
        it 'finds the permit' do
          expect(permits.for(agent, credential, resource)).to contain_exactly(permit)
        end
      end

      describe '#any?' do
        it 'passes' do
          expect(permits.any?(agent, credential, resource)).to be true
        end
      end
    end

    context 'and searching for a different user' do
      it 'does not find a permit' do
        expect(permits.any?(agent(id: 'other'), credential, resource)).to be false
      end
    end

    context 'and searching for a different credential' do
      it 'does not find a permit' do
        expect(permits.any?(agent, credential(id: 'other'), resource)).to be false
      end
    end

    context 'and searching for a different resource' do
      it 'does not find a permit' do
        expect(permits.any?(agent, credential, resource(id: 'other'))).to be false
      end
    end
  end

  ## Helper methods for creating permits, etc.

  def new_permit(agent, credential, resource, zone: '(all)')
    Checkpoint::DB::Permit.from(agent, credential, resource, zone: zone)
  end

  def agent(type: 'user', id: 'userid')
    user = double('user', agent_type: type, id: id)
    Checkpoint::Agent.new(user)
  end

  def credential(id: 'edit')
    Checkpoint::Credential::Permission.new(id)
  end

  def resource(type: 'resource', id: 1)
    entity = double('entity', resource_type: type, id: id)
    Checkpoint::Resource.new(entity)
  end
end
