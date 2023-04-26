RSpec.describe Admin::AdminPolicy, type: :policy do
  let(:user) { nil }
  let(:record) { nil }

  describe "additional methods" do
    describe "#moderator_or_admin?" do
      subject { described_class.new(user, record).send(:moderator_or_admin?) }

      context "when user is not a moderator or admin" do
        it { is_expected.to be_falsey }
      end

      context "when user is moderator" do
        let(:user) { create(:user, role: :moderator) }

        it { is_expected.to be_truthy }
      end

      context "when user is admin" do
        let(:user) { create(:user, role: :admin) }

        it { is_expected.to be_truthy }
      end
    end
  end
end
