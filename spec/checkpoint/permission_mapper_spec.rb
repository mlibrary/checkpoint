# frozen_string_literal: true

require 'checkpoint/permission_mapper'

RSpec.describe Checkpoint::PermissionMapper do
  subject(:mapper) { described_class.new }

  describe "#roles_granting" do
    it "expands :read to no roles" do
      expect(mapper.roles_granting(:read)).to eq []
    end
  end

  describe "#permissions_for" do
    it "maps :read as :read" do
      expect(mapper.permissions_for(:read)).to eq [:read]
    end

    it "maps 'read' as :read" do
      expect(mapper.permissions_for('read')).to eq [:read]
    end

    it "maps :edit as :edit" do
      expect(mapper.permissions_for(:edit)).to eq [:edit]
    end

    it "maps 'edit' as :edit" do
      expect(mapper.permissions_for('edit')).to eq [:edit]
    end
  end
end
