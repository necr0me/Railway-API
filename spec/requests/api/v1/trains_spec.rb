RSpec.describe "Api::V1::Trains", type: :request do
  let(:user) { create(:user) }

  let(:train) { create(:train) }

  describe "#show" do
    context "when user is unauthorized" do
      before do
        get "/api/v1/trains/#{train.id}"
      end

      it "returns UNAUTHORIZED" do
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

  describe "#show_stops" do
    let(:train) { create(:train, :train_with_stops) }

    before do
      get "/api/v1/trains/#{train.id}/stops"
    end

    it "returns OK and train with its stops included and number of pages" do
      expect(response).to have_http_status(:ok)

      expect(json_response[:train][:data][:id].to_i).to eq(train.id)
      expect(json_response[:stops][:data].map { _1[:id].to_i }).to eq(train.stops.pluck(:id))

      expect(json_response[:stops][:pages]).to eq(1 + train.stops.count / Pagy::DEFAULT[:items].to_i)
    end
  end
end
