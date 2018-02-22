# frozen_string_literal: true

RSpec.describe Checkpoint do
  it "has a version number" do
    expect(Checkpoint::VERSION).not_to be nil
  end
end
