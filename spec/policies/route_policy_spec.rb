require 'rails_helper'

RSpec.describe RoutePolicy, type: :policy do
  let(:route) { create(:route) }

  subject { described_class.new(user, route) }

  describe 'being visitor' do
    let(:user) { nil }

    it { is_expected.to permit_action(:show) }

    it { is_expected.to forbid_action(:create) }

    it { is_expected.to forbid_action(:add_station) }

    it { is_expected.to forbid_action(:remove_station) }

    it { is_expected.to forbid_action(:destroy) }
  end

  describe 'being user' do
    let(:user) { create(:user) }

    it { is_expected.to permit_action(:show) }

    it { is_expected.to forbid_action(:create) }

    it { is_expected.to forbid_action(:add_station) }

    it { is_expected.to forbid_action(:remove_station) }

    it { is_expected.to forbid_action(:destroy) }
  end

  describe 'being moderator' do
    let(:user) { create(:user, role: :moderator) }

    it { is_expected.to permit_action(:show) }

    it { is_expected.to permit_action(:create) }

    it { is_expected.to permit_action(:add_station) }

    it { is_expected.to permit_action(:remove_station) }

    it { is_expected.to permit_action(:destroy) }
  end

  describe 'being admin' do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to permit_action(:show) }

    it { is_expected.to permit_action(:create) }

    it { is_expected.to permit_action(:add_station) }

    it { is_expected.to permit_action(:remove_station) }

    it { is_expected.to permit_action(:destroy) }
  end
end

