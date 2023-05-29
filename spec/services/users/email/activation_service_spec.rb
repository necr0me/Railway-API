RSpec.describe Users::Email::ActivationService do
  subject(:service) { described_class.call(token: token) }

  let(:token) { user.confirmation_token }
  let(:user) { create(:unactivated_user) }

  describe "#activate" do
    context "when token is not presented" do
      let(:token) { "" }

      it "success? is false, returns error" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ confirmation_token: ["Token is not presented"] })
      end
    end

    context "when token is invalid (no user with such token)" do
      let(:token) { "other token" }

      it "success? is false, returns error" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ confirmation_token: ["Confirmation token is invalid"] })
      end
    end

    context "when error occurs during user update" do
      before do
        allow(User).to receive(:find_by).with(confirmation_token: token).and_return(user)
        allow(user).to receive(:save).and_return(false)
      end

      it "success? is false, returns error" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to be_kind_of(ActiveModel::Errors)
      end
    end

    context "when everything is ok" do
      let!(:unconfirmed_email) { user.unconfirmed_email }

      it "success? is true, data is activated user; changes user email and confirmation fields" do
        result = service

        expect(result).to be_success
        expect(result.data).to eq(user)

        expect(user.reload.email).to eq(unconfirmed_email)
        expect(user.activated).to be_truthy
        expect(user.unconfirmed_email).to be_nil
      end
    end
  end
end
