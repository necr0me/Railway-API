RSpec.describe "Api::V1::Profiles", type: :request do
  let(:user) { create(:user, :user_with_profile) }
  let(:profile) { user.profiles.first }
  let(:user_without_profile) { create(:user) }

  describe "#index" do
    context "when user is unauthorized" do
      before do
        get "/api/v1/profiles"
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized" do
      before do
        get "/api/v1/profiles", headers: auth_header
      end

      it "returns OK and correct user profiles" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:profiles][:data].map { _1["id"].to_i }).to eq(user.profiles.pluck(:id))
      end
    end
  end

  describe "#create" do
    context "when user is unauthorized" do
      before do
        post "/api/v1/profiles", params: {
          profile: attributes_for(:profile)
        }
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user authorized and tries to create profile with invalid data" do
      before do
        post "/api/v1/profiles",
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

      it "returns UNPROCESSABLE_ENTITY and error messages" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
      end
    end

    context "when user is authorized and his profile already exists" do
      before do
        post "/api/v1/profiles",
             params: {
               profile: attributes_for(:profile)
             },
             headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:message]).to eq("Something went wrong")
      end
    end

    context "when user is authorized and tries to create profile with valid data" do
      before do
        post "/api/v1/profiles",
             params: {
               profile: attributes_for(:profile)
             },
             headers: auth_header_for(user_without_profile)
      end

      it "returns 201 and creates profile" do
        expect(response).to have_http_status(:created)
        expect(user_without_profile.reload.profiles).not_to be_nil
        expect(Profile.last.user_id).to eq(user_without_profile.id)
      end
    end
  end

  describe "#update" do
    context "when user is unauthorized" do
      before do
        patch "/api/v1/profiles/#{profile.id}", params: {
          profile: attributes_for(:profile)
        }
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and tries to update with invalid data" do
      before do
        patch "/api/v1/profiles/#{profile.id}",
              params: {
                profile: {
                  name: "x"
                }
              },
              headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and error messages" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
        expect(json_response[:errors][:name]).to include(/is too short/)
      end
    end

    context "when user is authorized and tries to update with valid data" do
      before do
        patch "/api/v1/profiles/#{profile.id}",
              params: {
                profile: {
                  name: "Bogdan",
                  surname: "Choma"
                }
              },
              headers: auth_header
      end

      it "returns OK and updates user profile" do
        expect(response).to have_http_status(:ok)
        expect(user.profiles.last.name).to eq("Bogdan")
        expect(user.profiles.last.surname).to eq("Choma")
      end
    end
  end

  describe "#destroy" do
    context "when user is unauthorized" do
      before do
        delete "/api/v1/profiles/#{profile.id}"
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized but error occured" do
      before do
        allow(Profile).to receive(:find).and_return(profile)
        allow(profile).to receive(:destroy).and_return(false)

        delete "/api/v1/profiles/#{profile.id}", headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and errors" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
      end
    end

    context "when user is authorized and no error occured" do
      before do
        delete "/api/v1/profiles/#{profile.id}", headers: auth_header
      end

      it "returns OK and destroys profile" do
        expect(response).to have_http_status(:ok)
        expect { profile.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
