require 'rails_helper'

RSpec.describe Api::V1::RoutesController, type: :request do

  let(:route) { create(:route, :with_stations) }
  let(:empty_route) { create(:route) }
  let(:station) { create(:station) }

  let(:user_credentials) { create(:user, role: :moderator); attributes_for(:user) }

  describe '#show' do
    context 'when user is unauthorized' do
      before do
        get "/api/v1/routes/#{route.id}"
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'returns route' do
        expect(json_response['route']).to_not be_nil
        expect(json_response['route']['id']).to eq(route.id)
      end

      it 'returns stations in route' do
        expect(json_response['stations']).to_not be_nil
        expect(json_response['stations'].map { _1.send(:[], 'id') }).to eq(route.stations.pluck(:id))
      end
    end

    context 'when route does not exist' do
      before do
        get '/api/v1/routes/0'
      end

      it 'returns 404' do
        expect(response.status).to eq(404)
      end

      it 'contains message that cant find route with such id' do
        expect(json_response['message']).to eq("Couldn't find Route with 'id'=0")
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
        post '/api/v1/routes', headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 422' do
        expect(response.status).to eq(422)
      end

      it 'contains error message' do
        expect(json_response['errors']).to_not be_nil
      end
    end

    context 'when user is authorized' do
      before do
        login_with_api(user_credentials)
        post '/api/v1/routes', headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 201' do
        expect(response.status).to eq(201)
      end

      it 'creates route in db' do
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
             headers: {
               Authorization: "Bearer #{json_response['access_token']}"
             }
      end

      it 'returns 404' do
        expect(response.status).to eq(404)
      end

      it 'contains error message' do
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
             headers: {
               Authorization: "Bearer #{json_response['access_token']}"
             }
      end

      it 'returns 422' do
        expect(response.status).to eq(422)
      end

      it 'contains error message' do
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
             headers: {
               Authorization: "Bearer #{json_response['access_token']}"
             }
      end

      it 'returns 201' do
        expect(response.status).to eq(201)
      end

      it 'adds station to route' do
        expect(empty_route.reload.stations).to include(station)
      end

      it 'response contains added station' do
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
        delete "/api/v1/routes/0/remove_station/#{route.stations.first.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 404' do
        expect(response.status).to eq(404)
      end

      it 'contains error message' do
        expect(json_response['message']).to eq("Couldn't find Route with 'id'=0")
      end
    end

    context 'when user is authorized and station does not exist' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/routes/#{route.id}/remove_station/0", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 422' do
        expect(response.status).to eq(422)
      end

      it 'contains error message' do
        expect(json_response['errors']).to include(/Couldn't find StationOrderNumber/)
      end
    end

    context 'when user is authorized, route and station do exist' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/routes/#{route.id}/remove_station/#{route.stations.first.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'removes station from route' do
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

    context 'when user is authorized and route does not exist' do
      before do
        login_with_api(user_credentials)
        delete '/api/v1/routes/0', headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 404' do
        expect(response.status).to eq(404)
      end

      it 'contains message that cant find route with such id' do
        expect(json_response['message']).to eq("Couldn't find Route with 'id'=0")
      end
    end

    context 'when user is authorized and route does exist' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/routes/#{route.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 204' do
        expect(response.status).to eq(204)
      end

      it 'destroys route' do
        expect { route.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
