RSpec.describe CarriagePolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:record) { create(:carriage) }

  context "when user is nil" do
    let(:user) { nil }

    it { is_expected.to forbid_action(:show) }
  end

  context "when user role is :user" do
    let(:user) { create(:user) }

    it { is_expected.to permit_action(:show) }
  end

  context "when user role is :moderator" do
    let(:user) { create(:user, role: :moderator) }

    it { is_expected.to permit_action(:show) }
  end

  context "when user role is :admin" do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to permit_action(:show) }
  end
end
