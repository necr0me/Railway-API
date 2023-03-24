

RSpec.describe RoutePolicy, type: :policy do
  subject { described_class.new(user, route) }

  let(:route) { create(:route) }

  context "when user is nil" do
    let(:user) { nil }

    it { is_expected.to permit_action(:show) }

    it { is_expected.to forbid_actions(%i[create add_station remove_station destroy]) }
  end

  context "when user role is :user" do
    let(:user) { create(:user) }

    it { is_expected.to permit_action(:show) }

    it { is_expected.to forbid_actions(%i[create add_station remove_station destroy]) }
  end

  context "when user role is :moderator" do
    let(:user) { create(:user, role: :moderator) }

    it { is_expected.to permit_actions(%i[show create add_station remove_station destroy]) }
  end

  context "when user role is :admin" do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to permit_actions(%i[show create add_station remove_station destroy]) }
  end
end
