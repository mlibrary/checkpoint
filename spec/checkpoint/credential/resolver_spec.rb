# frozen_string_literal: true

require "support/fake_credentials"
require "checkpoint/credential/resolver"

RSpec.describe Checkpoint::Credential::Resolver do
  describe "expansion" do
    let(:resolver) { described_class.new }

    it "yields a list of permissions" do
      credentials = resolver.expand(:read)
      expect(credentials).to all(be_a Checkpoint::Credential::Permission)
    end

    it "does not have any expansion rules itself" do
      credentials = resolver.expand(:read)
      expect(credentials.length).to eq 1
    end

    context "with an object-oriented role/permission hierarchy" do
      let(:role) { FakeEditor.new }
      let(:permission) { FakeRead.new }
      let(:credentials) { resolver.expand(permission) }

      it "allows the credential to expand itself" do
        expect(credentials).to eq([permission, role])
      end
    end
  end

  describe "conversion" do
    let(:resolver) { described_class.new }

    context "with a symbol" do
      let(:credential) { resolver.convert(:read) }

      it "yields a Permission" do
        expect(credential).to be_a Checkpoint::Credential::Permission
      end

      it "uses the symbol converted to a string as the id" do
        expect(credential.id).to eq "read"
      end
    end

    context "with a string" do
      let(:credential) { resolver.convert("read") }

      it "yields a Permission" do
        expect(credential).to be_a Checkpoint::Credential::Permission
      end

      it "uses the string as the id" do
        expect(credential.id).to eq "read"
      end
    end

    context "with an action that implements #to_credential" do
      let(:license) { double("credential", type: "license", id: "drive") }
      let(:action) { double("action", to_credential: license) }
      let(:credential) { resolver.convert(action) }

      it "yields the custom credential" do
        expect(credential).to be license
      end
    end
  end
end
