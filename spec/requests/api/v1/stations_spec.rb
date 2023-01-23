require 'rails_helper'

RSpec.describe Api::V1::StationsController, type: :request do

  let(:station) { create(:station) }

  let(:user) { create(:user, role: :moderator) }
  let(:user_credentials) { user; attributes_for(:user) }

  describe '#index' do
    context 'when query params presented' do
      before do
        create_list(:station, 3, :with_three_stations)
        get '/api/v1/stations?station=Mo'
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'returns list of found stations' do
        expect(json_response.count).to eq(Station.where('name LIKE ?', "#{request.params[:station]}%").count)
      end
    end

    context 'without query params' do
      before do
        create_list(:station, 3, :with_three_stations)
        get '/api/v1/stations'
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'returns list of all stations' do
        expect(json_response.count).to eq(Station.count)
      end
    end
  end

  describe '#show' do
    context 'when station does exist' do
      before do
        get "/api/v1/stations/#{station.id}"
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'returns correct station' do
        expect(json_response['id']).to eq(station.id)
        expect(json_response['name']).to eq(station.name)
      end
    end
  end

  describe '#create' do
    context 'when user is unauthorized' do
      before do
        post '/api/v1/stations', params: {
          station: attributes_for(:station)
        }
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized but tries to create station with invalid data' do
      before do
        login_with_api(user_credentials)
        post '/api/v1/stations',
             params: {
               station: {
                 name: ' '
               }
             },
             headers: {
               Authorization: "Bearer #{json_response['access_token']}"
             }
      end

      it 'returns 422' do
        expect(response.status).to eq(422)
      end

      it 'contains error messages' do
        expect(json_response['errors']).to_not be_nil
      end
    end

    context 'when user is authorized and tries to create station with valid data' do
      before do
        login_with_api(user_credentials)
        post '/api/v1/stations',
             params: {
               station: {
                 name: 'some_name'
               }
             },
             headers: {
               Authorization: "Bearer #{json_response['access_token']}"
             }
      end

      it 'returns 201' do
        expect(response.status).to eq(201)
      end

      it 'creates station' do
        expect(Station.last.name).to eq('some_name')
      end
    end
  end

  describe '#update' do
    context 'when user is unauthorized' do
      before do
        patch "/api/v1/stations/#{station.id}", params: {
          station: {
            name: "new_name"
          }
        }
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized but tries to update station with invalid data' do
      before do
        login_with_api(user_credentials)
        patch "/api/v1/stations/#{station.id}",
              params: {
                station: {
                  name: ' '
                }
              },
              headers: {
                Authorization: "Bearer #{json_response['access_token']}"
              }
      end

      it 'returns 422' do
        expect(response.status).to eq(422)
      end

      it 'contains error messages' do
        expect(json_response).to_not be_nil
      end
    end

    context 'when user is authorized and tries to update station with valid data' do
      before do
        login_with_api(user_credentials)
        patch "/api/v1/stations/#{station.id}",
              params: {
                station: {
                  name: 'new_name'
                }
              },
              headers: {
                Authorization: "Bearer #{json_response['access_token']}"
              }
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'updates station attributes' do
        expect(Station.last.name).to eq('new_name')
      end
    end
  end

  describe '#destroy' do
    context 'when user is unauthorized' do
      before do
        delete "/api/v1/stations/#{station.id}"
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when error occurs during destroying of station' do
      before do
        allow_any_instance_of(Station).to receive(:destroy).and_return(false)
        allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(['Error message'])

        login_with_api(user_credentials)
        delete "/api/v1/stations/#{station.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 422 and error message' do
        expect(response).to have_http_status(422)
        expect(json_response['errors']).to include('Error message')
      end
    end

    context 'when user is authorized and station does exist' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/stations/#{station.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 204' do
        expect(response.status).to eq(204)
      end

      it 'destroys station' do
        expect { station.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
