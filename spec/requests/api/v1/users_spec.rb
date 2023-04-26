RSpec.describe "Api::V1::Users", type: :request do
  let(:user) { create(:user) }

  describe "#show" do
    context "when user is unauthorized" do
      before do
        get "/api/v1/users/#{user.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and user is correct" do
      before do
        get "/api/v1/users/#{user.id}", headers: auth_header
      end

      it "returns 200 and proper user" do
        expect(response).to have_http_status(:ok)

        expect(json_response[:user][:id]).to eq(user.id)
        expect(json_response[:user][:email]).to eq(user.email)
      end
    end
  end

  describe "#update" do
    context "when user is unauthorized" do
      before do
        patch "/api/v1/users/#{user.id}", params: {
          user: attributes_for(:user)
        }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user tries to update with invalid password" do
      before do
        patch "/api/v1/users/#{user.id}",
              params: {
                user: {
                  password: "x"
                }
              },
              headers: auth_header
      end

      it "returns 422 and contains error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
      end
    end

    context "when user tries to update with correct data" do
      before do
        patch "/api/v1/users/#{user.id}",
              params: {
                user: {
                  password: "new_password"
                }
              },
              headers: auth_header
      end

      it "returns 200 and updates user password" do
        expect(response).to have_http_status(:ok)
        expect(user.reload.authenticate("new_password")).to be_kind_of(User)
      end
    end
  end
end
