RSpec.describe TrainPolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:record) { create(:train) }

  context "when user is nil" do
    let(:user) { nil }

    it { is_expected.to forbid_action(:show) }

    it { is_expected.to permit_action(:show_stops) }
  end

  context "when user role is :user" do
    let(:user) { create(:user) }

    it { is_expected.to permit_actions(%i[show show_stops]) }
  end

  context "when user role is :moderator" do
    let(:user) { create(:user, role: :moderator) }

    it { is_expected.to permit_actions(%i[show show_stops])  }
  end

  context "when user role is :admin" do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to permit_actions(%i[show show_stops]) }
  end
end
