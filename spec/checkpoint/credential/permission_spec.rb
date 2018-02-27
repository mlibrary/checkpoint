# frozen_string_literal: true

require 'checkpoint/credential/permission'

RSpec.describe Checkpoint::Credential::Permission do
  describe '#new' do
    it 'takes and stores a name' do
      permission = described_class.new(name: 'name')
      expect(permission.name).to eq 'name'
    end
  end

  it 'has the permission type' do
    permission = described_class.new(name: 'name')
    expect(permission.type).to eq 'permission'
  end
end
