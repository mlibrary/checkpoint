# frozen_string_literal: true

require "checkpoint/credential/role_map_resolver"

RSpec.describe Checkpoint::Credential::RoleMapResolver do
  context "with an empty map" do
    let(:resolver) { described_class.new({}) }

    it "expands an action to a single permission" do
      permission = resolver.expand(:read)
      expect(permission).to eq [build_permission(:read)]
    end
  end

  context "with a fully explicit role map" do
    let(:roles) do
      {
        admin: [:read, :create, :edit, :delete],
        editor: [:read, :create, :edit],
        guest: [:read]
      }
    end

    let(:permissions) do
      {
        read: [:guest, :editor, :admin],
        create: [:editor, :admin],
        edit: [:editor, :admin],
        delete: [:admin]
      }
    end

    let(:read) { build_permission(:read) }
    let(:admin) { build_role(:admin) }
    let(:editor) { build_role(:editor) }
    let(:guest) { build_role(:guest) }
    let(:resolver) { described_class.new(roles) }

    it "provides access to the role map" do
      expect(resolver.role_map).to eq roles
    end

    it "inverts the role map as the permission map" do
      expect(unpack(resolver.permission_map)).to eq unpack(permissions)
    end

    it "expands an action to all roles that grant it" do
      credentials = resolver.expand(:read)
      expect(credentials).to include(guest, editor, admin)
    end
  end

  ### Utilities

  def build_permission(permission)
    Checkpoint::Credential::Permission.new(permission)
  end

  def build_role(role)
    Checkpoint::Credential::Role.new(role)
  end

  # Unpack a map to a flat, sorted set of pairs for easy comparison
  def unpack(hash)
    hash.flat_map do |key, values|
      values.map { |value| [key, value] }
    end.sort
  end
end
