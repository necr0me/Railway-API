RSpec.describe Users::Email::ResetService do
  subject(:service) { described_class.call(user: user) }

  let(:user) { create(:user) }

  describe "#call" do
    it "calls #reset"
  end

  describe "#reset" do
    context "when error occurs during token update" do
      before do
        allow(user).to receive(:save).and_return(false)
      end

      it "success? is false, return activemodel errors" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to be_kind_of(ActiveModel::Errors)
      end
    end

    context "when everything is ok" do
      it "success? is true; generates reset email token and sets time when this token was generated" do
        result = service

        expect(result).to be_success
        expect(user.reset_email_token).not_to be_nil
        expect(user.reset_email_sent_at).not_to be_nil
      end
    end
  end
end
