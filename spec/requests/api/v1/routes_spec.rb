require 'rails_helper'

RSpec.describe Api::V1::RoutesController, type: :request do

  let(:route) { create(:route, :route_with_stations) }
  let(:empty_route) { create(:route) }
  let(:station) { create(:station) }

  let(:user_credentials) { create(:user, role: :moderator); attributes_for(:user) }

  describe '#show' do
    context 'when user is unauthorized' do
      before do
        get "/api/v1/routes/#{route.id}"
      end

      it 'returns 200, route and stations in route' do
        expect(response.status).to eq(200)

        expect(json_response['route']['id']).to eq(route.id)

        expect(json_response['stations'].map { _1.send(:[], 'id') }).to eq(route.stations.pluck(:id))
      end
    end
  end

  describe '#create' do
    context 'when user is unauthorized' do
      before do
        post '/api/v1/routes'
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when error occurs during creating of route' do
      before do
        allow_any_instance_of(Route).to receive(:persisted?).and_return(false)

        login_with_api(user_credentials)
        post '/api/v1/routes', headers: auth_header
      end

      it 'returns 422 and error message' do
        expect(response.status).to eq(422)
        expect(json_response['errors']).to_not be_nil
      end
    end

    context 'when user is authorized' do
      before do
        login_with_api(user_credentials)
        post '/api/v1/routes', headers: auth_header
      end

      it 'returns 201 and creates route in db' do
        expect(response.status).to eq(201)
        expect(json_response['route']['id']).to eq(Route.last.id)
      end
    end
  end

  describe '#add_station' do
    context 'when user is unauthorized' do
      before do
        post "/api/v1/routes/#{empty_route.id}/add_station", params: {
          station_id: station.id
        }
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized and route does not exist' do
      before do
        login_with_api(user_credentials)
        post "/api/v1/routes/0/add_station",
             params: {
               station_id: station.id
             },
             headers: auth_header
      end

      it 'returns 404 and contains error message' do
        expect(response.status).to eq(404)
        expect(json_response['message']).to eq("Couldn't find Route with 'id'=0")
      end
    end

    context 'when user is authorized and station does not exist' do
      before do
        login_with_api(user_credentials)
        post "/api/v1/routes/#{empty_route.id}/add_station",
             params: {
               station_id: 0
             },
             headers: auth_header
      end

      it 'returns 422 and contains error message that station must exist' do
        expect(response.status).to eq(422)
        expect(json_response['errors']).to include(/Station must exist/)
      end
    end

    context 'when user is authorized, route and station do exist' do
      before do
        login_with_api(user_credentials)
        post "/api/v1/routes/#{empty_route.id}/add_station",
             params: {
               station_id: station.id
             },
             headers: auth_header
      end

      it 'returns 201, adds station to route and response contains added station' do
        expect(response.status).to eq(201)

        expect(empty_route.reload.stations).to include(station)

        expect(json_response['station']['id']).to eq(station.id)
      end
    end
  end

  describe '#remove_station' do
    context 'when user is unauthorized' do
      before do
        delete "/api/v1/routes/#{route.id}/remove_station/#{route.stations.first.id}"
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized and route does not exist' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/routes/0/remove_station/#{route.stations.first.id}", headers: auth_header
      end

      it 'returns 404 and contains error message' do
        expect(response.status).to eq(404)
        expect(json_response['message']).to eq("Couldn't find Route with 'id'=0")
      end
    end

    context 'when user is authorized and station does not exist' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/routes/#{route.id}/remove_station/0", headers: auth_header
      end

      it 'returns 422 and contains error message' do
        expect(response.status).to eq(422)
        expect(json_response['errors']).to include(/Couldn't find StationOrderNumber/)
      end
    end

    context 'when user is authorized, route and station do exist' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/routes/#{route.id}/remove_station/#{route.stations.first.id}", headers: auth_header
      end

      it 'returns 200 and removes stations from route' do
        expect(response.status).to eq(200)
        expect(route.reload.stations.pluck(:id)).to_not include(request.params[:station_id])
      end
    end
  end

  describe '#destroy' do
    context 'when user is unauthorized' do
      before do
        delete "/api/v1/routes/#{route.id}"
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when error occurs during destroying of route' do
      before do
        allow_any_instance_of(Route).to receive(:destroy).and_return(false)
        allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(['Error message'])

        login_with_api(user_credentials)
        delete "/api/v1/routes/#{route.id}", headers: auth_header
      end

      it 'returns 422 and error message' do
        expect(response).to have_http_status(422)
        expect(json_response['errors']).to include('Error message')
      end
    end

    context 'when user is authorized and route does exist' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/routes/#{route.id}", headers: auth_header
      end

      it 'returns 204 and destroys route' do
        expect(response.status).to eq(204)
        expect { route.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
