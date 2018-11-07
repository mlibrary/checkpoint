# frozen_string_literal: true

RSpec.describe Checkpoint::DB::Query::AC do
  let(:agents)      { [double('agent', token: 'agent:aid')] }
  let(:credentials) { [double('perm', token: 'perm:pid')] }
  subject(:query)   { described_class.new(agents, credentials) }

  describe 'conditions' do
    it 'include placeholders for agent tokens' do
      expect(query.conditions).to include(agent_token: [:'$at_0'])
    end

    it 'include placeholders for credential tokens' do
      expect(query.conditions).to include(credential_token: [:'$ct_0'])
    end
  end

  describe 'parameters' do
    it 'include agent tokens' do
      expect(query.parameters).to include(at_0: 'agent:aid')
    end

    it 'include credential tokens' do
      expect(query.parameters).to include(ct_0: 'perm:pid')
    end
  end
end
