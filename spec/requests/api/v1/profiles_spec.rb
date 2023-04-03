RSpec.describe "Api::V1::Profiles", type: :request do
  let(:user) { create(:user, :user_with_profile) }
  let(:user_without_profile) { create(:user) }

  describe "#show" do
    context "when user is unauthorized" do
      before do
        get "/api/v1/profile"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized" do
      before do
        get "/api/v1/profile", headers: auth_header
      end

      it "returns 200 and proper profile" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:profile][:user_id]).to eq(user.id)
      end
    end
  end

  describe "#create" do
    context "when user is unauthorized" do
      before do
        post "/api/v1/profile", params: {
          profile: attributes_for(:profile)
        }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user authorized and tries to create profile with invalid data" do
      before do
        post "/api/v1/profile",
             params: {
               profile: {
                 name: "x",
                 surname: "x",
                 patronymic: "x",
                 phone_number: "x",
                 passport_code: "x"
               }
             },
             headers: auth_header_for(user_without_profile)
      end

      it "returns 400 and error messages" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
      end
    end

    context "when user is authorized and his profile already exists" do
      before do
        post "/api/v1/profile",
             params: {
               profile: attributes_for(:profile)
             },
             headers: auth_header
      end

      it "returns 422 and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:message]).to eq("Seems like record with this data already exists")
      end
    end

    context "when user is authorized and tries to create profile with valid data" do
      before do
        post "/api/v1/profile",
             params: {
               profile: attributes_for(:profile)
             },
             headers: auth_header_for(user_without_profile)
      end

      it "returns 201 and creates profile" do
        expect(response).to have_http_status(:created)
        expect(user_without_profile.reload.profile).not_to be_nil
        expect(Profile.last.user_id).to eq(user_without_profile.id)
      end
    end
  end

  describe "#update" do
    context "when user is unauthorized" do
      before do
        patch "/api/v1/profile", params: {
          profile: attributes_for(:profile)
        }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and tries to update with invalid data" do
      before do
        patch "/api/v1/profile",
              params: {
                profile: {
                  name: "x"
                }
              },
              headers: auth_header
      end

      it "returns 422 and error messages" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
        expect(json_response[:errors][:name]).to include(/is too short/)
      end
    end

    context "when user is authorized and tries to update with valid data" do
      before do
        patch "/api/v1/profile",
              params: {
                profile: {
                  name: "Bogdan",
                  surname: "Choma"
                }
              },
              headers: auth_header
      end

      it "returns 200 and updates user profile" do
        expect(response).to have_http_status(:ok)
        expect(user.profile.name).to eq("Bogdan")
        expect(user.profile.surname).to eq("Choma")
      end
    end
  end
end
