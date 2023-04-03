RSpec.describe TicketPolicy, type: :policy do
  subject { described_class.new(user, ticket) }

  let(:ticket) { create(:ticket, user: user) }

  context "when user is nil" do
    subject { described_class.new(user, create(:ticket)) }

    let(:user) { nil }

    it { is_expected.to forbid_actions(%i[show create destroy]) }
  end

  context "when user role is :user" do
    let(:user) { create(:user) }

    context "when user is correct user (user is owner of ticket)" do
      it { is_expected.to permit_actions(%i[show create destroy]) }
    end

    context "when user is incorrect (user is not owner of ticket)" do
      let(:ticket) { create(:ticket, user: create(:user, email: "m@mail.com")) } # TODO: remove email after factory fix

      it { is_expected.to permit_actions(%i[create]) }

      it { is_expected.to forbid_actions(%i[show destroy]) }
    end
  end

  context "when user role is :moderator" do
    let(:user) { create(:user, role: :moderator) }
    let(:ticket) { create(:ticket, user: create(:user, email: "m@mail.com")) }

    it { is_expected.to permit_actions(%i[show create]) }

    it { is_expected.to forbid_actions(%i[destroy]) }
  end

  context "when user role is :admin" do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to permit_actions(%i[show create destroy]) }
  end
end
