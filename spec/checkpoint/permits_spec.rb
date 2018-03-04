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

RSpec.describe Checkpoint::Permits::Params do
  context 'with an array of items' do
    let(:item1)  { double('item', to_s: 'item1') }
    let(:item2)  { double('item', to_s: 'item2') }
    let(:items)  { [item1, item2] }
    let(:params) { described_class.new(items, 'prefix') }

    it 'gives an array with both placeholders, using the prefix' do
      expect(params.placeholders).to contain_exactly(:$prefix_0, :$prefix_1)
    end

    it 'gives a hash-convertible array with both values' do
      expect(params.values).to contain_exactly([:prefix_0, 'item1'], [:prefix_1, 'item2'])
    end
  end

  context 'with a single item' do
    let(:item)   { double('item', to_s: 'item') }
    let(:params) { described_class.new(item, 'prefix') }

    it 'gives an array of one placeholder, using the prefix' do
      expect(params.placeholders).to eq [:$prefix_0]
    end

    it 'gives a hash-convertible array of one value' do
      expect(params.values).to eq [[:prefix_0, 'item']]
    end
  end

  context 'with an item implementing sql_value' do
    let(:item)   { double('item', sql_value: 'sql_value') }
    let(:params) { described_class.new(item, 'prefix') }

    it 'uses the #sql_value and not #to_s' do
      expect(params.values).to eq [[:prefix_0, 'sql_value']]
    end
  end
end
