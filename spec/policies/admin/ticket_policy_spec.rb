RSpec.describe Admin::TicketPolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:user) { nil }
  let(:record) { create(:ticket) }

  context "when user role is nil" do
    it { is_expected.to forbid_action(:destroy) }
  end

  context "when user role is :user" do
    let(:user) { create(:user, email: "m@m.m") }

    it { is_expected.to forbid_action(:destroy) }
  end

  context "when user role is :moderator" do
    let(:user) { create(:user, role: :moderator, email: "m@m.m") }

    it { is_expected.to forbid_action(:destroy) }
  end

  context "when user role is :admin" do
    let(:user) { create(:user, role: :admin, email: "m@m.m") }

    it { is_expected.to permit_action(:destroy) }
  end
end
