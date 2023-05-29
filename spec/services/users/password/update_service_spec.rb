RSpec.describe Users::Password::UpdateService do
  subject(:service) { described_class.call(token: token, password: password) }

  let(:user) { create(:user, reset_password_token: token, reset_password_sent_at: DateTime.now.utc) }
  let(:token) { "token" }
  let(:password) { "12345678" }

  describe "#update" do
    context "when token is not presented" do
      let(:token) { "" }

      it "success? is false, returns error that token is not presented" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ reset_password_token: ["Token is not presented"] })
      end
    end

    context "when token is invalid" do
      let(:token) { "other token" }

      it "success? is false, returns error that token is invalid" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ reset_password_token: ["Token is invalid"] })
      end
    end

    context "when token has been expired" do
      before { create(:user, reset_password_token: token, reset_password_sent_at: DateTime.now.utc - 5.hours) }

      it "success? is false, returns error that token has expired" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ reset_password_token: ["Token has expired"] })
      end
    end

    context "when new password same as old one" do
      before { user }

      let(:password) { attributes_for(:user)[:password] }

      it "success? is false, returns error that new password is the same as old one" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ password: ["New password is the same as old one"] })
      end
    end

    context "when error occurs during user update" do
      before do
        allow(User).to receive(:find_by).with(reset_password_token: token).and_return(user)
        allow(user).to receive(:save).and_return(false)
      end

      it "success? is false, returns activemodel errors" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to be_kind_of(ActiveModel::Errors)
      end
    end

    context "when everything is ok" do
      before { user }

      it "success? is true, updates password" do
        result = service

        expect(result).to be_success

        expect(user.reload.authenticate(password)).to be_truthy
        expect(user.authenticate(attributes_for(:user)[:password])).to be_falsey
      end
    end
  end
end
