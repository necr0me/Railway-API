RSpec.describe Auth::AuthenticationService do
  let(:user) { create(:user) }

  describe "#authenticate" do
    context "when email is invalid" do
      it "contains error and doesnt return user" do
        result = described_class.call(user_params: { email: " ", password: " " })

        expect(result.error[:email]).to include("Can't find user with such email")
        expect(result.data).to be_nil
      end
    end

    context "when account is not activated" do
      let(:user) { create(:unactivated_user) }
      let(:user_params) { { email: user.email, password: attributes_for(:unactivated_user)[:password] } }

      it "contains error and doesnt return user" do
        result = described_class.call(user_params: user_params)

        expect(result.error[:email]).to include("Account is not activated")
        expect(result.data).to be_nil
      end
    end

    context "when password is invalid" do
      it "contains error message and does not return user" do
        result = described_class.call(user_params: { email: user.email, password: " " })

        expect(result.error[:password]).to include("Invalid password")
        expect(result.data).to be_nil
      end
    end

    context "when credentials are correct" do
      it "does not contains any errors and returns correct user" do
        result = described_class.call(user_params: { email: user.email, password: user.password })

        expect(result.error).to be_nil

        expect(result.data).not_to be_nil
        expect(result.data.id).to eq(user.id)
      end
    end
  end
end
