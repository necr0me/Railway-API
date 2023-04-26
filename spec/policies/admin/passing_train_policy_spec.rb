RSpec.describe Admin::PassingTrainPolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:user) { nil }
  let(:record) { create(:passing_train) }

  context "when user role is nil" do
    it { is_expected.to forbid_actions(%i[create update destroy]) }
  end

  context "when user role is :user" do
    let(:user) { create(:user) }

    it { is_expected.to forbid_actions(%i[create update destroy]) }
  end

  context "when user role is :moderator" do
    let(:user) { create(:user, role: :moderator) }

    it { is_expected.to permit_actions(%i[create update destroy]) }
  end

  context "when user role is :admin" do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to permit_actions(%i[create update destroy]) }
  end
end
