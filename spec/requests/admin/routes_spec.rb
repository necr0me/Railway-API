RSpec.describe "Admin::Routes", type: :request do
  let(:route) { create(:route, :route_with_stations) }
  let(:empty_route) { create(:route) }
  let(:station) { create(:station) }

  let(:user) { create(:user, role: :moderator) }

  describe "#index" do
    context "when user is unauthorized" do
      before do
        get "/admin/routes"
      end

      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized" do
      include_context "with sequence cleaner"

      before do
        create_list(:route, 6)
        get "/admin/routes#{page_param}", headers: auth_header
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

        it "returns ok, list all of 6 routes" do
          expect(response).to have_http_status(:ok)

          expect(json_response[:routes][:data].count).to eq(Route.count)
          expect(json_response[:pages]).to eq(1)
        end
      end
    end
  end

  describe "#show" do
    context "when user is unauthorized" do
      include_context "with sequence cleaner"

      before do
        get "/admin/routes/#{route.id}"
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
        get "/admin/routes/#{route.id}", headers: auth_header
      end

      it "returns OK, route, stations in route and available stations" do
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
        post "/admin/routes"
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when error occurs during creating of route" do
      include_context "with sequence cleaner"

      before do
        allow(Route).to receive(:create).and_return(route)
        allow(route).to receive(:persisted?).and_return(false)

        post "/admin/routes", headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
      end
    end

    context "when user is authorized" do
      before do
        post "/admin/routes", headers: auth_header
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
        post "/admin/routes/#{empty_route.id}/stations", params: {
          station_id: station.id
        }
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and route does not exist" do
      before do
        post "/admin/routes/0/stations",
             params: {
               station_id: station.id
             },
             headers: auth_header
      end

      it "returns NOT_FOUND and contains error message" do
        expect(response).to have_http_status(:not_found)
        expect(json_response[:message]).to eq("Couldn't find Route with 'id'=0")
      end
    end

    context "when user is authorized and station does not exist" do
      before do
        post "/admin/routes/#{empty_route.id}/stations",
             params: {
               station_id: 0
             },
             headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and contains error message that station must exist" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include(/Station must exist/)
      end
    end

    context "when user is authorized, route and station do exist" do
      before do
        post "/admin/routes/#{empty_route.id}/stations",
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
        delete "/admin/routes/#{route.id}/stations/#{route.stations.first.id}"
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and route does not exist" do
      before do
        delete "/admin/routes/0/stations/#{route.stations.first.id}", headers: auth_header
      end

      it "returns NOT_FOUND and contains error message" do
        expect(response).to have_http_status(:not_found)
        expect(json_response[:message]).to eq("Couldn't find Route with 'id'=0")
      end
    end

    context "when user is authorized and station does not exist" do
      before do
        delete "/admin/routes/#{route.id}/stations/0", headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and contains error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include(/Couldn't find StationOrderNumber/)
      end
    end

    context "when user is authorized, route and station do exist" do
      before do
        delete "/admin/routes/#{route.id}/stations/#{route.stations.first.id}", headers: auth_header
      end

      it "returns OK, removed station and removes stations from route" do
        expect(response).to have_http_status(:ok)

        expect(json_response[:station][:data][:id]).to eq(request.params[:station_id])

        expect(route.reload.stations.pluck(:id)).not_to include(request.params[:station_id])
      end
    end
  end

  describe "#update" do
    include_context "with sequence cleaner"

    let(:params) do
      {
        route: {
          standard_travel_time: ActiveSupport::Duration.build(2.days.to_i + 2.hours.to_i).iso8601
        }
      }
    end

    context "when user is unauthorized" do
      before do
        patch "/admin/routes/#{route.id}", params: params
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when error occurred during update" do
      let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }
      let(:routes) { Route.includes(:stations) }

      before do
        allow(Route).to receive(:includes).with(:stations).and_return(routes)
        allow(routes).to receive(:find).and_return(route)
        allow(route).to receive(:update).and_return(false)
        allow(route).to receive(:errors).and_return(errors)

        patch "/admin/routes/#{route.id}",
              headers: auth_header,
              params: params
      end

      it "returns UNPROCESSABLE_ENTITY and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when user is authorized and route exists" do
      before do
        patch "/admin/routes/#{route.id}",
              headers: auth_header,
              params: params
      end

      it "returns OK and updates route" do
        expect(response).to have_http_status(:ok)
        expect(route.reload.standard_travel_time.iso8601).to eq(params[:route][:standard_travel_time])
      end
    end
  end

  describe "#destroy" do
    include_context "with sequence cleaner"

    context "when user is unauthorized" do
      before do
        delete "/admin/routes/#{route.id}"
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when error occurs during destroying of route" do
      let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }
      let(:routes) { Route.includes(:stations) }

      before do
        allow(Route).to receive(:includes).with(:stations).and_return(routes)
        allow(routes).to receive(:find).and_return(route)
        allow(route).to receive(:destroy).and_return(false)
        allow(route).to receive(:errors).and_return(errors)

        delete "/admin/routes/#{route.id}", headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when user is authorized and route does exist" do
      before do
        delete "/admin/routes/#{route.id}", headers: auth_header
      end

      it "returns 204 and destroys route" do
        expect(response).to have_http_status(:no_content)
        expect { route.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
