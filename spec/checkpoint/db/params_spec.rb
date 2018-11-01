# frozen_string_literal: true

require 'checkpoint/db/params'

RSpec.describe Checkpoint::DB::Params do
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
