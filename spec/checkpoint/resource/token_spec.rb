# frozen_string_literal: true

require 'checkpoint/resource/token'

module Checkpoint
  RSpec.describe Resource::Token do
    subject(:resource) { described_class.new('a_type', 'an_id') }

    it 'returns its type' do
      expect(resource.type).to eq('a_type')
    end

    it 'returns its ID' do
      expect(resource.id).to eq('an_id')
    end

    context 'when given non-string inputs' do
      subject(:resource) { described_class.new(Object, 1) }

      it 'converts the type to a string' do
        expect(resource.type).to be_a String
        expect(resource.type).to eq('Object')
      end

      it 'converts the id to a string' do
        expect(resource.id).to be_a String
        expect(resource.id).to eq('1')
      end
    end

    it 'gives a string token with its type and ID' do
      expect(resource.to_s).to eq('a_type:an_id')
    end

    it 'gives a resource URI with its type and ID' do
      expect(resource.uri).to eq('resource://a_type/an_id')
    end

    describe '#inspect' do
      it 'gives the URI' do
        expect(resource.inspect).to eq('resource://a_type/an_id')
      end
    end

    describe '#token' do
      it 'returns itself' do
        expect(resource.token).to equal resource
      end
    end

    describe "#all" do
      it 'gives the special "all" resource' do
        expect(described_class.all).to be_a(described_class)
      end

      it 'always returns the same object' do
        all_one = described_class.all
        all_two = described_class.all
        expect(all_one).to equal(all_two)
      end

      it 'freezes the singleton' do
        all = described_class.all
        expect { all.instance_variable_set(:@type, 'any') }.to raise_error(RuntimeError)
      end
    end

    describe "#eql?" do
      it 'considers resources as the same if type and id match' do
        res1 = described_class.new('some-type', 'some-id')
        res2 = described_class.new('some-type', 'some-id')
        expect(res1).to eql(res2)
      end

      it 'considers resources as different if type does not match' do
        res1 = described_class.new('some-type', 'some-id')
        res2 = described_class.new('other-type', 'some-id')
        expect(res1).not_to eql(res2)
      end

      it 'considers resources as different if id does not match' do
        res1 = described_class.new('some-type', 'some-id')
        res2 = described_class.new('some-type', 'other-id')
        expect(res1).not_to eql(res2)
      end
    end

    describe "#==" do
      it 'considers resources as the same if type and id match' do
        res1 = described_class.new('some-type', 'some-id')
        res2 = described_class.new('some-type', 'some-id')
        expect(res1).to eq(res2)
      end

      it 'considers resources as different if type does not match' do
        res1 = described_class.new('some-type', 'some-id')
        res2 = described_class.new('other-type', 'some-id')
        expect(res1).not_to eq(res2)
      end

      it 'considers resources as different if id does not match' do
        res1 = described_class.new('some-type', 'some-id')
        res2 = described_class.new('some-type', 'other-id')
        expect(res1).not_to eq(res2)
      end
    end

    describe "#hash" do
      it 'gives the same value for equal tokens' do
        res1 = described_class.new('some-type', 'some-id')
        res2 = described_class.new('some-type', 'some-id')
        expect(res1.hash).to eq(res2.hash)
      end
    end
  end
end
