# frozen_string_literal: true

require 'checkpoint/credential_resolver'

class FakeRoles
  def permissions_for(action)
    [action.to_sym]
  end

  def roles_granting(action)
    case action.to_sym
    when :edit
      %i[editor admin]
    else
      []
    end
  end
end

class EmptyRoles
  def permissions_for(action)
    [action.to_sym]
  end

  def roles_granting(_action)
    []
  end
end

RSpec.describe Checkpoint::CredentialResolver do
  context "when no role permissions are defined" do
    let(:mapper) { EmptyRoles.new }
    subject(:resolver) { described_class.new(permission_mapper: mapper) }

    context "when resolving edit" do
      subject { resolver.resolve(:edit) }

      it "includes 'permission:edit'" do
        is_expected.to include('permission:edit')
      end

      it "does not include any roles" do
        is_expected.to eq(['permission:edit'])
      end
    end

    context "when resolving read" do
      subject { resolver.resolve(:read) }

      it "includes 'permission:read'" do
        is_expected.to include('permission:read')
      end

      it "does not include any roles" do
        is_expected.to eq(['permission:read'])
      end
    end

    it "accepts string actions" do
      expect(resolver.resolve('read')).to include('permission:read')
    end

    it "accepts symbol actions" do
      expect(resolver.resolve(:read)).to include('permission:read')
    end
  end

  context "when editor and admin roles grant edit permission" do
    let(:mapper)   { FakeRoles.new }
    let(:resolver) { described_class.new(permission_mapper: mapper) }

    context "when resolving edit" do
      subject { resolver.resolve(:edit) }

      it "includes 'permission:edit'" do
        is_expected.to include('permission:edit')
      end

      it "includes 'role:editor'" do
        is_expected.to include('role:editor')
      end

      it "includes 'role:admin'" do
        is_expected.to include('role:admin')
      end
    end

    context "when resolving destroy" do
      subject { resolver.resolve(:destroy) }

      it "includes ':edit'" do
        is_expected.to include('permission:destroy')
      end

      it "does not include any roles" do
        is_expected.to eq(['permission:destroy'])
      end
    end
  end
end
