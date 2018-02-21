# frozen_string_literal: true

require 'checkpoint/grant_repository'

RSpec.describe Checkpoint::GrantRepository do
  it "does not have any grants" do
    expect(subject.grants_for(nil, nil, nil)).to eq([])
  end
end
