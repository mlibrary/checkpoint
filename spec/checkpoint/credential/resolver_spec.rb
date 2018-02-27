# frozen_string_literal: true

require 'checkpoint/credential/resolver'

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
      let(:edit) { build_permission(:edit) }
      subject    { resolver.resolve(:edit) }

      it "includes 'permission:edit'" do
        is_expected.to include(edit)
      end

      it "does not include any roles" do
        is_expected.to contain_exactly(edit)
      end
    end

    context "when resolving read" do
      let(:read) { build_permission(:read) }
      subject    { resolver.resolve(:read) }

      it "includes 'permission:read'" do
        is_expected.to include(read)
      end

      it "does not include any roles" do
        is_expected.to contain_exactly(read)
      end
    end

    it "accepts string actions" do
      read = build_permission(:read)
      expect(resolver.resolve('read')).to include(read)
    end

    it "accepts symbol actions" do
      read = build_permission(:read)
      expect(resolver.resolve(:read)).to include(read)
    end
  end

  context "when editor and admin roles grant edit permission" do
    let(:mapper)   { FakeRoles.new }
    let(:resolver) { described_class.new(permission_mapper: mapper) }

    context "when resolving edit" do
      subject(:credentials) { resolver.resolve(:edit) }

      it "includes 'permission:edit'" do
        edit = build_permission(:edit)
        expect(credentials).to include(edit)
      end

      it "includes 'role:editor'" do
        editor = build_role(:editor)
        expect(credentials).to include(editor)
      end

      it "includes 'role:admin'" do
        admin = build_role(:admin)
        expect(credentials).to include(admin)
      end
    end

    context "when resolving destroy" do
      subject(:credentials) { resolver.resolve(:destroy) }

      it "includes ':edit'" do
        destroy = build_permission(:destroy)
        expect(credentials).to include(destroy)
      end

      it "does not include any roles" do
        destroy = build_permission(:destroy)
        expect(credentials).to contain_exactly(destroy)
      end
    end
  end

  context 'when resolving a Permission object' do
    let(:permission) { build_permission('name') }
    let(:mapper)     { double('mapper') }
    let(:resolver)   { described_class.new(permission_mapper: mapper) }

    it 'calls granted_by' do
      expect(permission).to receive(:granted_by)
      resolver.resolve(permission)
    end

    it 'does not call permissions_for on the mapper' do
      expect(mapper).not_to receive(:permissions_for)
      resolver.resolve(permission)
    end

    it 'does not call roles_granting on the mapper' do
      expect(mapper).not_to receive(:roles_granting)
      resolver.resolve(permission)
    end
  end

  context 'when resolving anything that implements #granted_by' do
    let(:credential) { double('credential', granted_by: ['foo']) }
    let(:resolver)   { described_class.new }

    it 'calls granted_by' do
      expect(credential).to receive(:granted_by)
      resolver.resolve(credential)
    end
  end

  def build_permission(permission)
    Checkpoint::Credential::Permission.new(permission)
  end

  def build_role(role)
    Checkpoint::Credential::Role.new(role)
  end
end
