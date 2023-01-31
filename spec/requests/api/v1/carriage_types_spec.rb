require 'rails_helper'

RSpec.describe Api::V1::CarriageTypesController, type: :request do

  let(:user) { create(:user, role: :admin) }

  let(:carriage_type) { create(:carriage_type) }
  let(:carriage_type_with_carriage) { create(:carriage_type, :type_with_carriage) }

  describe '#index' do
    context 'when user is unauthorised' do
      before do
        get '/api/v1/carriage_types'
      end

      it 'returns 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized' do
      before do
        create_list(:carriage_type, 2)
        get '/api/v1/carriage_types', headers: auth_header
      end

      it 'returns 200 and returns list of carraige types' do
        expect(response).to have_http_status(200)
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
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized and tries to create type with invalid data' do
      before do
        post '/api/v1/carriage_types',
             params: {
               carriage_type: {
                 name: 'x',
                 description: 'x' * 141,
                 capacity: -1
               }
             },
             headers: auth_header
      end

      it 'returns 422 and contains error messages'  do
        expect(response).to have_http_status(422)
        expect(json_response['errors']).to include(/Name is too short/,
                                                   /Description is too long/,
                                                   /Capacity must be greater than or equal to 0/)
      end
    end

    context 'when user is authorized and tries to create type with valid data' do
      before do
        post '/api/v1/carriage_types',
             params: {
               carriage_type: attributes_for(:carriage_type)
             },
             headers: auth_header
      end

      it 'returns 201 and created carriage type' do
        expect(response).to have_http_status(201)
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
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized and tries to update type with invalid data' do
      before do
        patch "/api/v1/carriage_types/#{carriage_type.id}",
              params: {
                carriage_type: {
                  name: carriage_type.name,
                  description: carriage_type.description,
                  capacity: -1
                }
              },
              headers: auth_header
      end

      it 'returns 422 and contains error message that validation failed' do
        expect(response).to have_http_status(422)
        expect(json_response['errors']).to include(/Validation failed/)
      end
    end

    context 'when user is authorized and tries to update type with valid data' do
      before do
        patch "/api/v1/carriage_types/#{carriage_type.id}",
              params: {
                carriage_type: {
                  name: carriage_type.name,
                  description: carriage_type.description,
                  capacity: 2
                }
              },
              headers: auth_header
      end

      it 'returns 200 and updated carriage type' do
        expect(response).to have_http_status(200)
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
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized and tries to destroy type with carriages' do
      before do
        delete "/api/v1/carriage_types/#{carriage_type_with_carriage.id}", headers: auth_header
      end

      it 'returns 422 and contains error message that cant delete type that has any carriages' do
        expect(response).to have_http_status(422)
        expect(json_response['errors']).to include("Can't destroy carriage type that has any carriages")
      end
    end

    context 'when user is authorize and tries to destroy type without any carriages' do
      before do
        delete "/api/v1/carriage_types/#{carriage_type.id}", headers: auth_header
      end

      it 'returns 204 and destroys type from db' do
        expect(response).to have_http_status(204)
        expect { carriage_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
