# frozen_string_literal: true

require 'checkpoint/permit_repository'

RSpec.describe Checkpoint::PermitRepository do
  it "does not have any permits" do
    expect(subject.permits_for(nil, nil, nil)).to eq([])
  end
end
