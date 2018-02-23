# frozen_string_literal: true

require 'checkpoint/permission_check'

RSpec.describe Checkpoint::PermissionCheck do
  let(:user)   { double('user') }
  let(:action) { :action }
  let(:target) { double('target') }

  subject(:check) { described_class.new(user, action, target) }

  it 'returns the user' do
    expect(check.user).to eq user
  end

  it 'returns the action' do
    expect(check.action).to eq action
  end

  it 'returns the target' do
    expect(check.target).to eq target
  end

  it 'rejects by default' do
    expect(check.satisfied?).to be false
  end

  context 'when there is no matching permit' do
    let(:authority) { double('authority', permits?: false) }
    subject(:check) do
      described_class.new(user, action, target, authority: authority)
    end

    it 'is not satisifed?' do
      expect(check.satisfied?).to be false
    end
  end

  context 'when there is a matching permit' do
    let(:authority) { double('authority', permits?: true) }
    subject(:check) do
      described_class.new(user, action, target, authority: authority)
    end

    it 'is satisfied?' do
      expect(check.satisfied?).to be true
    end
  end
end
