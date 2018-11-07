# frozen_string_literal: true

RSpec.describe Checkpoint::DB::Query::CR do
  let(:credentials) { [double('perm', token: 'perm:pid')] }
  let(:resources)   { [double('entity', token: 'entity:eid')] }
  subject(:query)   { described_class.new(credentials, resources) }

  describe 'conditions' do
    it 'include placeholders for credential tokens' do
      expect(query.conditions).to include(credential_token: [:'$ct_0'])
    end

    it 'include placeholders for resource tokens' do
      expect(query.conditions).to include(resource_token: [:'$rt_0'])
    end
  end

  describe 'parameters' do
    it 'include credential tokens' do
      expect(query.parameters).to include(ct_0: 'perm:pid')
    end

    it 'include resource tokens' do
      expect(query.parameters).to include(rt_0: 'entity:eid')
    end
  end
end
