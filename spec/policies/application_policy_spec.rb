RSpec.describe ApplicationPolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:user) { nil }
  let(:record) { nil }

  describe "policy" do
    it { is_expected.to forbid_actions(%i[index show create new update edit destroy]) }
  end

  describe "scope" do
    describe "#resolve" do
      let(:resolved_scope) { described_class::Scope.new(nil, nil).resolve }

      it "raises NotImplementedError" do
        expect { resolved_scope }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "additional methods" do
    subject { described_class.new(user, record).send(:owned_by_user?) }

    let(:user) { create(:user) }
    let(:record) { double }

    describe "#owned_by_user?" do
      context "when user does not own the record" do
        before do
          allow(record).to receive(:user_id).and_return(0)
        end

        it { is_expected.to be_falsey }
      end

      context "when user own the record" do
        before do
          allow(record).to receive(:user_id).and_return(user.id)
        end

        it { is_expected.to be_truthy }
      end
    end
  end
end
