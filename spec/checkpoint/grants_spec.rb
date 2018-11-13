# frozen_string_literal: true

require 'sequel_helper'

require 'checkpoint/agent/token'
require 'checkpoint/credential/token'
require 'checkpoint/resource/token'
require 'checkpoint/grants'

# Note that this is tagged with DB, which triggers setup and teardown
# of a clean database on each example.
RSpec.describe Checkpoint::Grants, DB: true do
  subject(:grants) { described_class.new }

  describe '#grant!' do
    it "adds one grant" do
      grant = grants.grant! agent, credential, resource
      expect(grants.for(agent, credential, resource)).to contain_exactly(grant)
    end
  end

  describe '#revoke!' do
    it "deletes the grant" do
      grants.grant!(agent, credential, resource)
      grants.revoke!(agent, credential, resource)
      expect(grants.any?(agent, credential, resource)).to be false
    end

    it "does not delete other grants" do
      grants.grant!(agent, credential, resource(id: 'one'))
      grant = grants.grant!(agent, credential, resource(id: 'two'))
      grants.revoke!(agent, credential, resource(id: 'one'))

      expect(grants.for(agent, credential, resource(id: 'two'))).to contain_exactly(grant)
    end
  end

  context 'when storing one grant in the default zone' do
    let!(:grant) { grants.grant!(agent, credential, resource) }

    context 'and searching for it' do
      describe '#for' do
        it 'finds the grant' do
          expect(grants.for(agent, credential, resource)).to contain_exactly(grant)
        end
      end

      describe '#any?' do
        it 'passes' do
          expect(grants.any?(agent, credential, resource)).to be true
        end
      end
    end

    context 'and searching for a different user' do
      it 'does not find a grant' do
        expect(grants.any?(agent(id: 'other'), credential, resource)).to be false
      end
    end

    context 'and searching for a different credential' do
      it 'does not find a grant' do
        expect(grants.any?(agent, credential(id: 'other'), resource)).to be false
      end
    end

    context 'and searching for a different resource' do
      it 'does not find a grant' do
        expect(grants.any?(agent, credential, resource(id: 'other'))).to be false
      end
    end
  end

  context 'when searching a small fixture of grants' do
    let(:a1)   { agent(id: 'one') }
    let(:a2)   { agent(id: 'two') }

    let(:read) { credential(id: 'read') }
    let(:edit) { credential(id: 'edit') }

    let(:r1)   { resource(id: 'one') }
    let(:r2)   { resource(id: 'two') }

    let!(:read11) { grants.grant!(a1, read, r1) }
    let!(:read21) { grants.grant!(a2, read, r1) }
    let!(:edit21) { grants.grant!(a2, edit, r1) }
    let!(:read22) { grants.grant!(a2, read, r2) }

    context 'for read on resource one' do
      subject(:agent_grants) { grants.who(read, r1) }

      it 'finds the grants for both agents' do
        expect(agent_grants).to contain_exactly(read11, read21)
      end
    end

    context 'for read/edit on resource one' do
      subject(:agent_grants) { grants.who([read, edit], r1) }

      it 'finds the three grants across both agents' do
        expect(agent_grants).to contain_exactly(read11, read21, edit21)
      end
    end

    context 'for read on either resource' do
      subject(:agent_grants) { grants.who(read, [r1, r2]) }

      it 'finds the three read grants' do
        expect(agent_grants).to contain_exactly(read11, read21, read22)
      end
    end

    context 'for read or edit on either resource' do
      subject(:agent_grants) { grants.who([read, edit], [r1, r2]) }

      it 'finds all four grants' do
        expect(agent_grants).to contain_exactly(read11, read21, edit21, read22)
      end
    end

    context 'for what agent two can do with resource one' do
      subject(:credential_grants) { grants.what(a2, r1) }

      it 'finds the read and edit grants' do
        expect(credential_grants).to contain_exactly(read21, edit21)
      end
    end

    context 'for what either agent can do with resource one' do
      subject(:credential_grants) { grants.what([a1, a2], r1) }

      it 'finds the three grants on resource one' do
        expect(credential_grants).to contain_exactly(read11, read21, edit21)
      end
    end

    context 'for what agent two can do with either resource' do
      subject(:credential_grants) { grants.what(a2, [r1, r2]) }

      it 'finds the three grants for agent two' do
        expect(credential_grants).to contain_exactly(read21, edit21, read22)
      end
    end

    context 'for what either agent can do with either resource' do
      subject(:credential_grants) { grants.what([a1, a2], [r1, r2]) }

      it 'finds all four grants' do
        expect(credential_grants).to contain_exactly(read11, read21, edit21, read22)
      end
    end

    context 'for resources agent two can read' do
      subject(:resource_grants) { grants.which(a2, read) }

      it 'finds read grants on both resources' do
        expect(resource_grants).to contain_exactly(read21, read22)
      end
    end

    context 'for resources either agent can read' do
      subject(:resource_grants) { grants.which([a1, a2], read) }

      it 'finds the three grants across agents' do
        expect(resource_grants).to contain_exactly(read11, read21, read22)
      end
    end

    context 'for resources agent two can read or edit' do
      subject(:resource_grants) { grants.which(a2, [read, edit]) }

      it 'finds the three grants across permissions' do
        expect(resource_grants).to contain_exactly(read21, edit21, read22)
      end
    end

    context 'for resources either agent can read or edit' do
      subject(:resource_grants) { grants.which([a1, a2], [read, edit]) }

      it 'finds all four grants' do
        expect(resource_grants).to contain_exactly(read11, read21, edit21, read22)
      end
    end
  end

  ## Helper methods for creating grants, etc.

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
