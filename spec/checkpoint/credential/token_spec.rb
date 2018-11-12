# frozen_string_literal: true

require 'checkpoint/credential/token'

module Checkpoint
  RSpec.describe Credential::Token do
    subject(:credential) { described_class.new('a_type', 'an_id') }

    it 'returns its type' do
      expect(credential.type).to eq('a_type')
    end

    it 'returns its ID' do
      expect(credential.id).to eq('an_id')
    end

    context 'when given non-string inputs' do
      subject(:credential) { described_class.new(Object, 1) }

      it 'converts the type to a string' do
        expect(credential.type).to be_a String
        expect(credential.type).to eq('Object')
      end

      it 'converts the id to a string' do
        expect(credential.id).to be_a String
        expect(credential.id).to eq('1')
      end
    end

    it 'gives a string token with its type and ID' do
      expect(credential.to_s).to eq('a_type:an_id')
    end

    it 'gives a credential URI with its type and ID' do
      expect(credential.uri).to eq('credential://a_type/an_id')
    end

    describe '#inspect' do
      it 'gives the URI' do
        expect(credential.inspect).to eq('credential://a_type/an_id')
      end
    end

    describe '#token' do
      it 'returns itself' do
        expect(credential.token).to equal credential
      end
    end

    describe "#eql?" do
      it 'considers credentials as the same if type and id match' do
        credential1 = described_class.new('some-type', 'some-id')
        credential2 = described_class.new('some-type', 'some-id')
        expect(credential1).to eql(credential2)
      end

      it 'considers credentials as different if type does not match' do
        credential1 = described_class.new('some-type', 'some-id')
        credential2 = described_class.new('other-type', 'some-id')
        expect(credential1).not_to eql(credential2)
      end

      it 'considers credentials as different if id does not match' do
        credential1 = described_class.new('some-type', 'some-id')
        credential2 = described_class.new('some-type', 'other-id')
        expect(credential1).not_to eql(credential2)
      end
    end

    describe "#==" do
      it 'considers credentials as the same if type and id match' do
        credential1 = described_class.new('some-type', 'some-id')
        credential2 = described_class.new('some-type', 'some-id')
        expect(credential1).to eq(credential2)
      end

      it 'considers credentials as different if type does not match' do
        credential1 = described_class.new('some-type', 'some-id')
        credential2 = described_class.new('other-type', 'some-id')
        expect(credential1).not_to eq(credential2)
      end

      it 'considers credentials as different if id does not match' do
        credential1 = described_class.new('some-type', 'some-id')
        credential2 = described_class.new('some-type', 'other-id')
        expect(credential1).not_to eq(credential2)
      end
    end

    describe "#hash" do
      it 'gives the same value for equal tokens' do
        credential1 = described_class.new('some-type', 'some-id')
        credential2 = described_class.new('some-type', 'some-id')
        expect(credential1.hash).to eq(credential2.hash)
      end
    end
  end
end
