RSpec.describe "Api::V1::Routes", type: :request do
  let(:route) { create(:route, :route_with_stations) }
  let(:empty_route) { create(:route) }
  let(:station) { create(:station) }

  let(:user) { create(:user, role: :moderator) }

  describe "#index" do
    context "when user is unauthorized" do
      before do
        get "/api/v1/routes"
      end

      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and query param page presented" do
      include_context "with sequence cleaner"

      before do
        create_list(:route, 6)
        get "/api/v1/routes#{page_param}", headers: auth_header
      end

      context "when page param is presented" do
        let(:page_param) { "?page=2" }

        it "returns ok, list of 1 route and number of pages" do
          expect(response).to have_http_status(:ok)

          expect(json_response[:routes][:data].count).to eq(1)
          expect(json_response[:pages]).to eq((Route.count / 5.0).ceil)
        end
      end

      context "when page param is not presented" do
        let(:page_param) { "" }

        it "returns ok, list of 5 routes (first page) and number of pages" do
          expect(response).to have_http_status(:ok)

          expect(json_response[:routes][:data].count).to eq(5)
          expect(json_response[:pages]).to eq((Route.count / 5.0).ceil)
        end
      end
    end
  end

  describe "#show" do
    context "when user is unauthorized" do
      include_context "with sequence cleaner"

      before do
        get "/api/v1/routes/#{route.id}"
      end

      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized" do
      let(:available_stations) { Station.where.not(id: route.stations.pluck(:id)).pluck(:id) }

      include_context "with sequence cleaner"

      before do
        create(:station, name: "I am new station")
        get "/api/v1/routes/#{route.id}", headers: auth_header
      end

      it "returns 200, route, stations in route and available stations" do
        expect(response).to have_http_status(:ok)

        expect(json_response[:route][:data][:id].to_i).to eq(route.id)

        expect(json_response[:route][:included].map { _1[:id].to_i }).to eq(route.stations.pluck(:id))

        expect(json_response[:available_stations][:data].map { _1[:id].to_i }).to include(*available_stations)
      end
    end
  end

  describe "#create" do
    context "when user is unauthorized" do
      before do
        post "/api/v1/routes"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when error occurs during creating of route" do
      before do
        allow_any_instance_of(Route).to receive(:persisted?).and_return(false)

        post "/api/v1/routes", headers: auth_header
      end

      it "returns 422 and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
      end
    end

    context "when user is authorized" do
      before do
        post "/api/v1/routes", headers: auth_header
      end

      it "returns 201 and creates route in db" do
        expect(response).to have_http_status(:created)
        expect(json_response[:route][:data][:id].to_i).to eq(Route.last.id)
      end
    end
  end

  describe "#add_station" do
    context "when user is unauthorized" do
      before do
        post "/api/v1/routes/#{empty_route.id}/add_station", params: {
          station_id: station.id
        }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and route does not exist" do
      before do
        post "/api/v1/routes/0/add_station",
             params: {
               station_id: station.id
             },
             headers: auth_header
      end

      it "returns 404 and contains error message" do
        expect(response).to have_http_status(:not_found)
        expect(json_response[:message]).to eq("Couldn't find Route with 'id'=0")
      end
    end

    context "when user is authorized and station does not exist" do
      before do
        post "/api/v1/routes/#{empty_route.id}/add_station",
             params: {
               station_id: 0
             },
             headers: auth_header
      end

      it "returns 422 and contains error message that station must exist" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include(/Station must exist/)
      end
    end

    context "when user is authorized, route and station do exist" do
      before do
        post "/api/v1/routes/#{empty_route.id}/add_station",
             params: {
               station_id: station.id
             },
             headers: auth_header
      end

      it "returns 201, adds station to route and response contains added station" do
        expect(response).to have_http_status(:created)

        expect(empty_route.reload.stations).to include(station)

        expect(json_response[:station][:data][:id].to_i).to eq(station.id)
      end
    end
  end

  describe "#remove_station" do
    include_context "with sequence cleaner"

    context "when user is unauthorized" do
      before do
        delete "/api/v1/routes/#{route.id}/remove_station/#{route.stations.first.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and route does not exist" do
      before do
        delete "/api/v1/routes/0/remove_station/#{route.stations.first.id}", headers: auth_header
      end

      it "returns 404 and contains error message" do
        expect(response).to have_http_status(:not_found)
        expect(json_response[:message]).to eq("Couldn't find Route with 'id'=0")
      end
    end

    context "when user is authorized and station does not exist" do
      before do
        delete "/api/v1/routes/#{route.id}/remove_station/0", headers: auth_header
      end

      it "returns 422 and contains error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include(/Couldn't find StationOrderNumber/)
      end
    end

    context "when user is authorized, route and station do exist" do
      before do
        delete "/api/v1/routes/#{route.id}/remove_station/#{route.stations.first.id}", headers: auth_header
      end

      it "returns 200, removed station and removes stations from route" do
        expect(response).to have_http_status(:ok)

        expect(json_response[:station][:data][:id]).to eq(request.params[:station_id])

        expect(route.reload.stations.pluck(:id)).not_to include(request.params[:station_id])
      end
    end
  end

  describe "#destroy" do
    include_context "with sequence cleaner"

    context "when user is unauthorized" do
      before do
        delete "/api/v1/routes/#{route.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when error occurs during destroying of route" do
      before do
        allow_any_instance_of(Route).to receive(:destroy).and_return(false)
        allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(["Error message"])

        delete "/api/v1/routes/#{route.id}", headers: auth_header
      end

      it "returns 422 and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when user is authorized and route does exist" do
      before do
        delete "/api/v1/routes/#{route.id}", headers: auth_header
      end

      it "returns 204 and destroys route" do
        expect(response).to have_http_status(:no_content)
        expect { route.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
