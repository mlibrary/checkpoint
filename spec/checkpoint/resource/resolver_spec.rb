# frozen_string_literal: true

require 'checkpoint/resource'
require 'checkpoint/resource/resolver'

RSpec.describe Checkpoint::ResourceResolver do
  let(:resolver) { described_class.new }

  context 'with an entity' do
    let(:listing)       { double('Listing', id: 12, resource_type: 'listing') }
    subject(:resources) { resolver.resolve(listing) }

    it 'resolves to only the entity and type resources' do
      entity = build('listing', '12')
      type   = build('listing', all_ids)
      expect(resources).to contain_exactly(entity, type)
    end
  end

  def build(type, id)
    Checkpoint::Resource.new(type, id)
  end

  def all_ids
    Checkpoint::Resource::ALL
  end
end
