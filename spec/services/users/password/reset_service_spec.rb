RSpec.describe Users::Password::ResetService do
  subject(:service) { described_class.call(email: email) }

  let(:email) { user.email }
  let(:user) { create(:user) }

  describe "#reset_password" do
    context "when no user with such email" do
      let(:email) { "" }

      it "success? is false, return error that user with such email is not registered" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ email: ["User with such email is not registered"] })
      end
    end

    context "when account with such email is not activated" do
      let(:user) { create(:unactivated_user) }
      let(:email) { user.unconfirmed_email }

      it "success? is false, returns error that account is not activated" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ email: ["Account is not activated"] })
      end
    end

    context "when error occurs during user update" do
      before do
        allow(User).to receive(:find_by).and_return(nil)
        allow(User).to receive(:find_by).with(email: email).and_return(user)
        allow(user).to receive(:save).and_return(false)
      end

      it "success? is false, returns activemodel errors" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to be_kind_of(ActiveModel::Errors)
      end
    end

    context "when everything is ok" do
      it "success? is true, generates reset_password_token and time when it was generated" do
        result = service

        expect(result).to be_success

        expect(user.reload.reset_password_token).not_to be_nil
        expect(user.reset_password_sent_at).not_to be_nil
      end
    end
  end
end
