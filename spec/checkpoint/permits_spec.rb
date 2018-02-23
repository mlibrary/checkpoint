# frozen_string_literal: true

require 'checkpoint/permits'

RSpec.describe Checkpoint::Permits do
  subject(:permits) { described_class.new }

  it "does not have any permits" do
    expect(permits.for(nil, nil, nil)).to eq([])
  end
end
