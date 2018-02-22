# frozen_string_literal: true

require 'checkpoint/resource_resolver'

RSpec.describe Checkpoint::ResourceResolver do
  let(:listing1)  { double('Listing', id: 12, entity_type: 'listing') }
  let(:listing2)  { double('Listing', id: 13, entity_type: 'listing') }
  let(:newspaper) { double('Newspaper', id: 8, entity_type: 'newspaper') }

  subject(:resolver) { described_class.new }

  it "resolves a listing to its entity token" do
    expect(resolver.resolve(listing1)).to include('listing:12')
  end

  it "resolves another listing to its entity token" do
    expect(resolver.resolve(listing2)).to include('listing:13')
  end

  it "resolves a listing to its type token" do
    expect(resolver.resolve(listing1)).to include('type:listing')
  end

  it "resolves a newspaper to its entity token" do
    expect(resolver.resolve(newspaper)).to include('newspaper:8')
  end

  it "resolves a newspaper to its type token" do
    expect(resolver.resolve(newspaper)).to include('type:newspaper')
  end
end
