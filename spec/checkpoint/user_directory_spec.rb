# frozen_string_literal: true

require 'checkpoint/user_directory'

RSpec.describe Checkpoint::UserDirectory do
  describe "#attributes_for" do
    let(:user) { double('User') }
    subject(:directory) { described_class.new }

    it "gives an empty attribute hash" do
      expect(directory.attributes_for(user)).to eq({})
    end
  end
end
