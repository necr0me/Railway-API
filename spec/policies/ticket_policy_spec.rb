RSpec.describe TicketPolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:record) { create(:ticket, profile: profile) }

  let(:profile) { create(:profile, user: user) }

  let(:other_user) { create(:user, email: "m@m.m") } # TODO: remove email after factory fix
  let(:other_profile) { create(:profile, phone_number: "1" * 7, passport_code: "KH#{'1' * 7}", user: other_user) }

  context "when user is nil" do
    let(:record) { create(:ticket) }
    let(:user) { nil }

    it { is_expected.to forbid_actions(%i[index create destroy]) }
  end

  context "when user role is :user" do
    let(:user) { create(:user) }

    context "when user is correct user (user is owner of ticket)" do
      it { is_expected.to permit_actions(%i[index create destroy]) }
    end

    context "when user is incorrect (user is not owner of ticket)" do
      let(:record) { create(:ticket, profile: other_profile) }

      it { is_expected.to permit_actions(%i[index create]) }

      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context "when user role is :moderator" do
    let(:user) { create(:user, role: :moderator) }

    context "when user is correct user (user is owner of ticket)" do
      it { is_expected.to permit_actions(%i[index create destroy]) }
    end

    context "when user is incorrect (user is not owner of ticket)" do
      let(:record) { create(:ticket, profile: other_profile) }

      it { is_expected.to permit_actions(%i[index create]) }

      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context "when user role is :admin" do
    let(:user) { create(:user, role: :admin) }

    context "when user is correct user (user is owner of ticket)" do
      it { is_expected.to permit_actions(%i[index create destroy]) }
    end

    context "when user is incorrect (user is not owner of ticket)" do
      let(:record) { create(:ticket, profile: other_profile) }

      it { is_expected.to permit_actions(%i[index create]) }

      it { is_expected.to forbid_action(:destroy) }
    end
  end
end
