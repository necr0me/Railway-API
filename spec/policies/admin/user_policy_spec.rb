RSpec.describe Admin::UserPolicy, type: :policy do
  subject { described_class.new(user, resource_user) }

  let(:user) { nil }
  let(:resource_user) { create(:user, email: "m@m.m") } # TODO: unique email generation

  context "when user role is nil" do
    it { is_expected.to forbid_action(:destroy) }
  end

  context "when user role is :user" do
    let(:user) { create(:user) }

    it { is_expected.to forbid_action(:destroy) }
  end

  context "when user role is :moderator" do
    let(:user) { create(:user, role: :moderator) }

    it { is_expected.to forbid_action(:destroy) }
  end

  context "when user role is :admin" do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to permit_action(:destroy) }
  end
end
