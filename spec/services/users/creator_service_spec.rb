RSpec.describe Users::CreatorService do
  subject(:service) { described_class.call(user_params: user_params) }

  let(:user_params) { { unconfirmed_email: unconfirmed_email, password: password } }
  let(:unconfirmed_email) { "johndoe@gmail.com" }
  let(:password) { "password" }

  describe "#call" do
    it "calls #create"
  end

  describe "#create" do
    context "when unconfirmed_email is blank" do
      let(:unconfirmed_email) { "" }

      it "success? is false, error is not nil" do
        result = service

        expect(result).not_to be_success
        expect(result.error).not_to be_nil
      end
    end

    context "when user params are invalid" do
      let(:password) { "" }

      it "success? is false, error is array of activemodel errors" do
        result = service

        expect(result).not_to be_success
        expect(result.error).not_to be_nil
        expect(result.error).to be_kind_of(ActiveModel::Errors)
      end
    end

    context "when error occurs during token generation" do
      let(:user) { create(:user, email: "mail@milo.com") }

      before do
        allow(User).to receive(:new).and_return(user)
        allow(user).to receive(:save).and_return(false)
      end

      it "success? is false, error is array of activemodel errors" do
        result = service

        expect(result).not_to be_success
        expect(result.error).not_to be_nil
        expect(result.error).to be_kind_of(ActiveModel::Errors)
      end
    end

    context "when everything is ok" do
      it "success? is true, error is nil, creates unactivated user with confirmation token" do
        result = service
        user = User.last

        expect(result).to be_success
        expect(result.error).to be_nil

        expect(user.unconfirmed_email).to eq(unconfirmed_email)
        expect(user.confirmation_token).not_to be_nil
        expect(user.activated).to be_falsey
      end
    end
  end
end
