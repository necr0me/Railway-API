RSpec.describe "Api::V1::Stations", type: :request do
  let(:station) { create(:station) }

  let(:user) { create(:user) }

  describe "#index" do
    include_context "with sequence cleaner"

    # TODO: make tests better (when number of stations < 5 and > 5)
    context "when query param 'station' presented" do
      let(:found_stations) { Station.where("name LIKE ?", "#{request.params[:station]}%") }

      before do
        create_list(:station, 3, :station_sequence_with_name_list)
        get "/api/v1/stations?station=Mo"
      end

      it "returns OK, list of 5 or less found stations and number of pages" do
        expect(response).to have_http_status(:ok)

        expect(json_response[:stations][:data].count).to eq(found_stations.size)
        expect(json_response[:pages]).to eq((found_stations.size / 5.0).ceil)
      end
    end

    context "when query param 'page' presented" do
      before do
        create_list(:station, 6, :station_sequence_with_n_stations)
        get "/api/v1/stations?page=1"
      end

      it "returns OK, list of 5 stations and number of pages" do
        expect(response).to have_http_status(:ok)

        expect(json_response[:stations][:data].count).to eq(5)
        expect(json_response[:pages]).to eq((Station.count / 5.0).ceil)
      end
    end

    context "without query params" do
      before do
        create_list(:station, 3, :station_sequence_with_name_list)
        get "/api/v1/stations"
      end

      it "returns OK and list of all stations" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:stations][:data].count).to eq(Station.count)
      end
    end
  end

  describe "#show" do
    context "when station does exist" do
      before do
        get "/api/v1/stations/#{station.id}"
      end

      it "returns OK and proper station" do
        expect(response).to have_http_status(:ok)

        expect(json_response[:station][:data][:id].to_i).to eq(station.id)
        expect(json_response[:station][:data][:attributes][:name]).to eq(station.name)
      end
    end
  end
end
