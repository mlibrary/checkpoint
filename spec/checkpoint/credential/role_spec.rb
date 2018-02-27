# frozen_string_literal: true

require 'checkpoint/credential/role'

RSpec.describe Checkpoint::Credential::Role do
  describe '#new' do
    it 'takes and stores a name' do
      role = described_class.new('name')
      expect(role.name).to eq 'name'
    end
  end

  it 'has the role type' do
    role = described_class.new('name')
    expect(role.type).to eq 'role'
  end
end
