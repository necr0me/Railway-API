require 'rails_helper'

RSpec.describe Api::V1::CarriagesController, type: :request do
  let(:user) { create(:user, role: :admin) }
  let(:user_credentials) { user; attributes_for(:user) }

  let(:carriage_type) { create(:carriage_type) }

  let(:carriage) { create(:carriage) }

  describe '#index' do
    context 'when user is unauthorized' do
      before do
        get '/api/v1/carriages'
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized' do
      before do
        create_list(:carriage, 2)
        login_with_api(user_credentials)
        get '/api/v1/carriages', headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'returns list of carriages' do
        expect(json_response['carriages'].count).to eq(Carriage.all.count)
      end
    end
  end

  describe '#show' do
    context 'when user is unauthorized' do
      before do
        get "/api/v1/carriages/#{carriage.id}"
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized' do
      before do
        login_with_api(user_credentials)
        get "/api/v1/carriages/#{carriage.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'returns proper carriage' do
        expect(json_response['carriage']['id']).to eq(carriage.id)
      end
    end
  end

  describe '#create' do
    context 'when user is unauthorized' do
      before do
        post '/api/v1/carriages', params: {
          carriage: attributes_for(:carriage)
        }
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized and tries to create carriage with invalid data' do
      before do
        login_with_api(user_credentials)
        post '/api/v1/carriages',
             params: {
               carriage: {
                 name: 'x',
                 carriage_type_id: carriage_type.id
               }
             },
             headers: {
               Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 422' do
        expect(response.status).to eq(422)
      end

      it 'returns error message that name is too short' do
        expect(json_response['errors']).to include(/Name is too short/)
      end
    end

    context 'when user is authorized and tries to create carriage with valid data' do
      before do
        login_with_api(user_credentials)
        post '/api/v1/carriages',
             params: {
               carriage: {
                 name: 'New_name',
                 carriage_type_id: carriage_type.id
               }
             },
             headers: {
               Authorization: "Bearer #{json_response['access_token']}"
             }
      end

      it 'returns 201' do
        expect(response.status).to eq(201)
      end

      it 'returns created carriage' do
        expect(json_response['carriage']['id']).to eq(Carriage.last.id)
      end
    end
  end

  describe '#update' do
    context 'when user is unauthorized' do
      before do
        patch "/api/v1/carriages/#{carriage.id}", params: {
          carriage: {
            name: 'New_name'
          }
        }
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized and tries to update carriage with invalid data' do
      before do
        login_with_api(user_credentials)
        patch "/api/v1/carriages/#{carriage.id}",
              params: {
                carriage: {
                  name: 'x'
                }
              },
              headers: {
                Authorization: "Bearer #{json_response['access_token']}"
              }
      end

      it 'returns 422' do
        expect(response.status).to eq(422)
      end

      it 'contains error message that name is too short' do
        expect(json_response['errors']).to include(/Name is too short/)
      end
    end

    context 'when user is authorized and tries to update carriage with valid data' do
      before do
        login_with_api(user_credentials)
        patch "/api/v1/carriages/#{carriage.id}",
              params: {
                carriage: {
                  name: 'New_name'
                }
              },
              headers: {
                Authorization: "Bearer #{json_response['access_token']}"
              }
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'returns updated carriage' do
        expect(json_response['carriage']['id']).to eq(carriage.id)
        expect(carriage.reload.name).to eq('New_name')
      end
    end
  end

  describe '#destroy' do
    context 'when user is unauthorized' do
      before do
        delete "/api/v1/carriages/#{carriage.id}"
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized and tries to destroy carriage' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/carriages/#{carriage.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 204' do
        expect(response.status).to eq(204)
      end

      it 'deletes carriage from db' do
        expect { carriage.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
