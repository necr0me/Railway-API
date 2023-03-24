

RSpec.describe StationPolicy, type: :policy do
  subject { described_class.new(user, station) }

  let(:station) { create(:station) }

  context "when user is nil" do
    let(:user) { nil }

    it { is_expected.to permit_actions(%i[index show]) }

    it { is_expected.to forbid_actions(%i[create update destroy]) }
  end

  context "when user role is :user" do
    let(:user) { create(:user) }

    it { is_expected.to permit_actions(%i[index show]) }

    it { is_expected.to forbid_actions(%i[create update destroy]) }
  end

  context "when user role is :moderator" do
    let(:user) { create(:user, role: :moderator) }

    it { is_expected.to permit_actions(%i[index show create update destroy]) }
  end

  context "when user role is :admin" do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to permit_actions(%i[index show create update destroy]) }
  end
end
