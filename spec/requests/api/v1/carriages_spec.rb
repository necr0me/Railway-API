RSpec.describe "Api::V1::Carriages", type: :request do
  let(:user) { create(:user) }

  let(:carriage) { create(:carriage) }

  describe "#show" do
    context "when user is unauthorized" do
      before do
        get "/api/v1/carriages/#{carriage.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized" do
      before do
        get "/api/v1/carriages/#{carriage.id}", headers: auth_header
      end

      it "returns 200 and proper carriage" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:carriage][:data][:id].to_i).to eq(carriage.id)
      end
    end
  end
end
