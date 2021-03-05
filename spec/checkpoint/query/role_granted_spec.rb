# frozen_string_literal: true

require "checkpoint/query/role_granted"

RSpec.describe Checkpoint::Query::RoleGranted do
  let(:user) { double("user") }
  let(:role) { :role }
  let(:target) { double("target") }

  subject(:check) { described_class.new(user, role, target) }

  it "returns the user" do
    expect(check.user).to eq user
  end

  it "returns the role" do
    expect(check.role).to eq role
  end

  it "returns the target" do
    expect(check.target).to eq target
  end

  it "rejects by default" do
    expect(check.true?).to be false
  end

  context "when there is no matching grant" do
    let(:authority) { double("authority", permits?: false) }
    subject(:check) do
      described_class.new(user, role, target, authority: authority)
    end

    it "is not true?" do
      expect(check.true?).to be false
    end
  end

  context "when there is a matching grant" do
    let(:authority) { double("authority", permits?: true) }
    subject(:check) do
      described_class.new(user, role, target, authority: authority)
    end

    it "is true?" do
      expect(check.true?).to be true
    end
  end
end
