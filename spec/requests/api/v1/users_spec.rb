RSpec.describe "Api::V1::Users", type: :request do
  let(:user) { create(:user) }

  describe "#show" do
    context "when user is unauthorized" do
      before do
        get "/api/v1/users"
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and user is correct" do
      before do
        get "/api/v1/users", headers: auth_header
      end

      it "returns OK and proper user" do
        expect(response).to have_http_status(:ok)

        expect(json_response[:user][:data][:id].to_i).to eq(user.id)
        expect(json_response[:user][:data][:attributes][:email]).to eq(user.email)
      end
    end
  end

  describe "#activate" do
    context "when error occurs" do
      let(:service) { instance_double(Users::Email::ActivationService, success?: false, error: ["Error message"]) }

      before do
        allow(Users::Email::ActivationService).to receive(:call).and_return(service)
        post "/api/v1/users/activate"
      end

      it "returns UNPROCESSABLE_ENTITY and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when everything is ok" do
      let(:user) { create(:unactivated_user) }
      let(:token) { user.confirmation_token }

      before { post "/api/v1/users/activate", params: { token: token } }

      it "returns OK and activates users" do
        expect(response).to have_http_status(:ok)
        expect(user.reload.activated).to be_truthy
      end
    end
  end

  describe "#reset_email" do
    context "when user is unauthorized" do
      before { post "/api/v1/users/reset_email" }

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when error occurs" do
      let(:service) { instance_double(Users::Email::ResetService, success?: false, error: ["Error message"]) }

      before do
        allow(Users::Email::ResetService).to receive(:call).and_return(service)
        post "/api/v1/users/reset_email", headers: auth_header
      end

      it "returns BAD_REQUEST and error message" do
        expect(response).to have_http_status(:bad_request)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when everything is ok" do
      before { post "/api/v1/users/reset_email", headers: auth_header }

      it "returns OK and generates reset email token" do
        expect(response).to have_http_status(:ok)
        expect(user.reload.reset_email_token).not_to be_nil
      end
    end
  end

  describe "#update_email" do
    context "when user is unauthorized" do
      before { patch "/api/v1/users/update_email" }

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when error occurs" do
      let(:service) { instance_double(Users::Email::UpdateService, success?: false, error: ["Error message"]) }

      before do
        allow(Users::Email::UpdateService).to receive(:call).and_return(service)
        patch "/api/v1/users/update_email", headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when everything is ok" do
      let(:user) { create(:user, reset_email_token: token, reset_email_sent_at: DateTime.now.utc) }

      let(:token) { "token" }
      let(:new_email) { "new_email@gmail.com" }

      before do
        patch "/api/v1/users/update_email",
              headers: auth_header,
              params: { token: token, email: new_email }
      end

      it "returns OK and updates user unconfirmed_email" do
        expect(response).to have_http_status(:ok)
        expect(user.reload.unconfirmed_email).to eq(new_email)
      end
    end
  end

  describe "#reset_password" do
    context "when error occurs" do
      let(:service) { instance_double(Users::Password::ResetService, success?: false, error: ["Error message"]) }

      before do
        allow(Users::Password::ResetService).to receive(:call).and_return(service)
        post "/api/v1/users/reset_password"
      end

      it "returns BAD_REQUEST and error message" do
        expect(response).to have_http_status(:bad_request)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when everything is ok" do
      before { post "/api/v1/users/reset_password", params: { email: user.email } }

      it "returns OK and generates reset password token" do
        expect(response).to have_http_status(:ok)
        expect(user.reload.reset_password_token).not_to be_nil
      end
    end
  end

  describe "#update_password" do
    context "when error occurs" do
      let(:service) { instance_double(Users::Password::UpdateService, success?: false, error: ["Error message"]) }

      before do
        allow(Users::Password::UpdateService).to receive(:call).and_return(service)
        patch "/api/v1/users/update_password"
      end

      it "returns UNPROCESSABLE_ENTITY and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when everything is ok" do
      let!(:user) { create(:user, reset_password_token: token, reset_password_sent_at: DateTime.now.utc) }

      let(:token) { "token" }
      let(:password) { SecureRandom.hex(4) }

      before { patch "/api/v1/users/update_password", params: { token: token, password: password } }

      it "returns OK and updates user password" do
        expect(response).to have_http_status(:ok)
        expect(user.reload.authenticate(password)).to be_truthy
      end
    end
  end
end
