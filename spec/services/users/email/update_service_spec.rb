RSpec.describe Users::Email::UpdateService do
  subject(:service) { described_class.call(token: token, email: email) }

  let(:token) { "token" }
  let(:email) { "newemail@gmail.com" }
  let(:user) { create(:user, reset_email_token: token, reset_email_sent_at: DateTime.now.utc) }

  describe "#update" do
    context "when token is not presented" do
      let(:token) { "" }

      it "success? is false, returns error that token is not presented" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ reset_email_token: ["Token is not presented"] })
      end
    end

    context "when token is invalid" do
      let(:other_token) { "other token" }

      it "success? is false, returns error that token is invalid" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ reset_email_token: ["Token is invalid"] })
      end
    end

    context "when token has expired" do
      before { create(:user, reset_email_token: token, reset_email_sent_at: DateTime.now.utc - 5.hours) }

      it "success? is false, returns error that token has expired" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ reset_email_token: ["Token has expired"] })
      end
    end

    context "when new email same as old one" do
      let(:email) { user.email }

      it "success? is false, returns error that new email same as old one" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to match({ unconfirmed_email: ["New email same as old one"] })
      end
    end

    context "when error occurs during user update" do
      before do
        allow(User).to receive(:find_by).with(reset_email_token: token).and_return(user)
        allow(user).to receive(:save).and_return false
      end

      it "success? is false, returns activemodel errors" do
        result = service

        expect(result).not_to be_success
        expect(result.error).to be_kind_of(ActiveModel::Errors)
      end
    end

    context "when everything is ok" do
      before { user }

      it "success? is true; generates confirmation token, unconfirmed_email equals new email" do
        result = service

        expect(result).to be_success

        expect(user.reload.reset_email_token).to be_nil
        expect(user.reset_email_sent_at).to be_nil

        expect(user.unconfirmed_email).to eq(email)
        expect(user.confirmation_token).not_to be_nil
      end
    end
  end
end
