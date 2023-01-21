require 'rails_helper'

RSpec.describe Api::V1::CarriageTypesController, type: :request do
  let(:user) { create(:user, role: :admin) }
  let(:user_credentials) { user; attributes_for(:user) }

  let(:carriage_type) { create(:carriage_type) }
  let(:carriage_type_with_carriage) { create(:carriage_type, :type_with_carriage) }

  describe '#index' do
    context 'when user is unauthorised' do
      before do
        get '/api/v1/carriage_types'
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized' do
      before do
        create_list(:carriage_type, 2)
        login_with_api(user_credentials)
        get '/api/v1/carriage_types', headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'returns list of carriage types' do
        expect(json_response['carriage_types'].count).to eq(CarriageType.count)
      end
    end
  end

  describe '#create' do
    context 'when user is unauthorized' do
      before do
        post '/api/v1/carriage_types', params: attributes_for(:carriage_type)
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized and tries to create type with invalid data' do
      before do
        login_with_api(user_credentials)
        post '/api/v1/carriage_types',
             params: {
               carriage_type: {
                 name: 'x',
                 description: 'x' * 141,
                 capacity: -1
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
        expect(json_response['errors']).to include(/Name is too short/,
                                                   /Description is too long/,
                                                   /Capacity must be greater than or equal to 0/)
      end
    end

    context 'when user is authorized and tries to create type with valid data' do
      before do
        login_with_api(user_credentials)
        post '/api/v1/carriage_types',
             params: {
               carriage_type: attributes_for(:carriage_type)
             },
             headers: {
               Authorization: "Bearer #{json_response['access_token']}"
             }
      end

      it 'returns 201' do
        expect(response.status).to eq(201)
      end

      it 'returns created carriage type' do
        expect(json_response['carriage_type']['id']).to eq(CarriageType.last.id)
      end
    end
  end

  describe '#update' do
    context 'when user is unauthorized' do
      before do
        patch "/api/v1/carriage_types/#{carriage_type.id}", params: attributes_for(:carriage_type)
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized and tries to update type with invalid data' do
      before do
        login_with_api(user_credentials)
        patch "/api/v1/carriage_types/#{carriage_type.id}",
              params: {
                carriage_type: {
                  name: carriage_type.name,
                  description: carriage_type.description,
                  capacity: -1
                }
              },
              headers: {
                Authorization: "Bearer #{json_response['access_token']}"
              }
      end

      it 'returns 422' do
        expect(response.status).to eq(422)
      end

      it 'contains error message that validation failed' do
        expect(json_response['errors']).to include(/Validation failed/)
      end
    end

    context 'when user is authorized and tries to update type with valid data' do
      before do
        login_with_api(user_credentials)
        patch "/api/v1/carriage_types/#{carriage_type.id}",
              params: {
                carriage_type: {
                  name: carriage_type.name,
                  description: carriage_type.description,
                  capacity: 2
                }
              },
              headers: {
                Authorization: "Bearer #{json_response['access_token']}"
              }
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'returns updated carriage type' do
        expect(json_response['carriage_type']['id']).to eq(carriage_type.id)
        expect(json_response['carriage_type']['capacity']).to eq(2)
      end
    end
  end

  describe '#destroy' do
    context 'when user is unauthorized' do
      before do
        delete "/api/v1/carriage_types/#{carriage_type.id}"
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized and tries to destroy type with carriages' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/carriage_types/#{carriage_type_with_carriage.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 422' do
        expect(response.status).to eq(422)
      end

      it 'contains error message that cant delete type that has any carriages' do
        expect(json_response['errors']).to include("Can't destroy carriage type that has any carriages")
      end
    end

    context 'when user is authorize and tries to destroy type without any carriages' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/carriage_types/#{carriage_type.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 204' do
        expect(response.status).to eq(204)
      end

      it 'destroys type from db' do
        expect { carriage_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end