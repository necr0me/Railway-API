RSpec.describe "Api::V1::Trains", type: :request do
  let(:user) { create(:user) }

  let(:train) { create(:train) }

  describe "#show" do
    context "when user is unauthorized" do
      before do
        get "/api/v1/trains/#{train.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # TODO: test included
    context "when user is authorized" do
      before do
        get "/api/v1/trains/#{train.id}", headers: auth_header
      end

      it "returns proper train" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:train][:data][:id].to_i).to eq(train.id)
      end
    end
  end
end
