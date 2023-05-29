RSpec.describe ProfilePolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:record) { create(:profile, user: user) }

  context "when user is nil" do
    let(:record) { create(:profile) }
    let(:user) { nil }

    it { is_expected.to forbid_actions(%i[index create update destroy]) }
  end

  context "when user role is :user" do
    let(:user) { create(:user) }

    context "when user does not owns profiles" do
      let(:record) { create(:profile, user: create(:user, email: "m@m.m")) }

      it { is_expected.to forbid_actions(%i[update destroy]) }

      it { is_expected.to permit_actions(%i[index create]) }
    end

    context "when user owns profiles" do
      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end
  end

  context "when user role is :moderator" do
    let(:user) { create(:user, role: :moderator) }

    context "when user does not owns profiles" do
      let(:record) { create(:profile, user: create(:user, email: "m@m.m")) }

      it { is_expected.to forbid_actions(%i[update destroy]) }

      it { is_expected.to permit_actions(%i[index create]) }
    end

    context "when user owns profiles" do
      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end
  end

  context "when user role is :admin" do
    let(:user) { create(:user, role: :admin) }

    context "when user does not owns profiles" do
      let(:record) { create(:profile, user: create(:user, email: "m@m.m")) }

      it { is_expected.to forbid_actions(%i[update destroy]) }

      it { is_expected.to permit_actions(%i[index create]) }
    end

    context "when user owns profiles" do
      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end
  end
end
