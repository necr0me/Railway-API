require 'rails_helper'

RSpec.describe Api::V1::StationsController, type: :request do

  let(:station) { create(:station) }

  let(:user) { create(:user, role: :moderator) }

  describe '#index' do
    context 'when query params presented' do
      before do
        create_list(:station, 3, :station_sequence_with_three_stations)
        get '/api/v1/stations?station=Mo'
      end

      it 'returns 200 and list of found stations' do
        expect(response).to have_http_status(200)
        expect(json_response.count).to eq(Station.where('name LIKE ?', "#{request.params[:station]}%").count)
      end
    end

    context 'without query params' do
      before do
        create_list(:station, 3, :station_sequence_with_three_stations)
        get '/api/v1/stations'
      end

      it 'returns 200 and list of all stations' do
        expect(response).to have_http_status(200)
        expect(json_response.count).to eq(Station.count)
      end
    end
  end

  describe '#show' do
    context 'when station does exist' do
      before do
        get "/api/v1/stations/#{station.id}"
      end

      it 'returns 200 and proper station' do
        expect(response).to have_http_status(200)

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
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized but tries to create station with invalid data' do
      before do
        post '/api/v1/stations',
             params: {
               station: {
                 name: ' '
               }
             },
             headers: auth_header
      end

      it 'returns 422 and contains error messages' do
        expect(response).to have_http_status(422)
        expect(json_response['errors']).to_not be_nil
      end
    end

    context 'when user is authorized and tries to create station with valid data' do
      before do
        post '/api/v1/stations',
             params: {
               station: {
                 name: 'some_name'
               }
             },
             headers: auth_header
      end

      it 'returns 201 and creates station' do
        expect(response).to have_http_status(201)

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
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized but tries to update station with invalid data' do
      before do
        patch "/api/v1/stations/#{station.id}",
              params: {
                station: {
                  name: ' '
                }
              },
              headers: auth_header
      end

      it 'returns 422 and contains error messages' do
        expect(response).to have_http_status(422)
        expect(json_response).to_not be_nil
      end
    end

    context 'when user is authorized and tries to update station with valid data' do
      before do
        patch "/api/v1/stations/#{station.id}",
              params: {
                station: {
                  name: 'new_name'
                }
              },
              headers: auth_header
      end

      it 'returns 200 and updates station attribute' do
        expect(response).to have_http_status(200)
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
        expect(response).to have_http_status(401)
      end
    end

    context 'when error occurs during destroying of station' do
      before do
        allow_any_instance_of(Station).to receive(:destroy).and_return(false)
        allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(['Error message'])

        delete "/api/v1/stations/#{station.id}", headers: auth_header
      end

      it 'returns 422 and error message' do
        expect(response).to have_http_status(422)
        expect(json_response['errors']).to include('Error message')
      end
    end

    context 'when user is authorized and station does exist' do
      before do
        delete "/api/v1/stations/#{station.id}", headers: auth_header
      end

      it 'returns 204 and destroys station' do
        expect(response).to have_http_status(204)
        expect { station.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
