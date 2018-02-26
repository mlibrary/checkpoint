# frozen_string_literal: true

require 'checkpoint/resource/resolver'

RSpec.describe Checkpoint::ResourceResolver do
  let(:resolver) { described_class.new }

  context 'with an entity' do
    let(:listing)       { double('Listing', id: 12, resource_type: 'listing') }
    subject(:resources) { resolver.resolve(listing) }

    it 'resolves to only the entity and type resources' do
      entity   = Checkpoint::Resource.new(listing)
      wildcard = Checkpoint::Resource::AllOfType.new(listing)
      expect(resources).to contain_exactly(entity, wildcard)
    end
  end
end
