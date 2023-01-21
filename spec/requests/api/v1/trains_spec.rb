require 'rails_helper'

RSpec.describe Api::V1::TrainsController, type: :request do
  let(:user) { create(:user, role: :admin) }
  let(:user_credentials) { user; attributes_for(:user) }

  let(:train) { create(:train) }
  let(:train_with_carriages) { create(:train, :train_with_carriages) }

  let(:route) { create(:route) }

  let(:carriage) { create(:carriage) }
  let(:carriage_with_train) { create(:carriage, train_id: train.id) }

  describe '#index' do
    context 'when user is unauthorized' do
      before do
        get '/api/v1/trains'
      end

      it 'returns 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized' do
      before do
        create_list(:train, 2)
        login_with_api(user_credentials)
        get '/api/v1/trains', headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns list of trains' do
        expect(response).to have_http_status(200)
        expect(json_response['trains'].count).to eq(2)
      end
    end
  end

  describe '#show' do
    context 'when user is unauthorized' do
      before do
        get "/api/v1/trains/#{train.id}"
      end

      it 'returns 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized' do
      before do
        login_with_api(user_credentials)
        get "/api/v1/trains/#{train.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns proper train' do
        expect(response).to have_http_status(200)
        expect(json_response['train']['id']).to eq(train.id)
      end
    end
  end

  describe '#create' do
    context 'when user is unauthorized' do
      before do
        post '/api/v1/trains', params: {
          train: {
            route_id: route.id
          }
        }
      end

      it 'returns 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized and tries to create train with not existing route' do
      # after rescuing from ActiveRecord::InvalidForeignKey
    end

    context 'when user is authorized and tries to create train with route' do
      before do
        login_with_api(user_credentials)
        post '/api/v1/trains', params: {
          train: {
            route_id: route.id
          }
        }, headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'creates train and returns it to user' do
        expect(response).to have_http_status(201)
        expect(json_response['message']).to eq('Train was successfully created')
        expect(json_response['train']['id']).to eq(Train.last.id)
      end
    end
  end

  describe '#update' do
    context 'when user is unauthorized' do
      before do
        patch "/api/v1/trains/#{train.id}", params: {
          train: {
            route_id: route.id
          }
        }
      end

      it 'returns 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized and error occurs during update' do
      before do
        allow_any_instance_of(Train).to receive(:update).and_return(false)
        allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(['Error message'])

        login_with_api(user_credentials)
        patch "/api/v1/trains/#{train.id}", params: {
          train: {
            route_id: route.id
          }
        }, headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 422 and errors' do
        expect(response).to have_http_status(422)
        expect(json_response['message']).to eq('Something went wrong')
        expect(json_response['errors']).to include('Error message')
      end
    end

    context 'when user is authorized and updates with correct data' do
      before do
        login_with_api(user_credentials)
        patch "/api/v1/trains/#{train.id}", params: {
          train: {
            route_id: route.id
          }
        }, headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'updates train attributes and returns updated train' do
        expect(response).to have_http_status(200)
        expect(json_response['message']).to eq('Train was successfully updated')
        expect(json_response['train']['route_id']).to eq(route.id)
      end
    end
  end

  describe '#add_carriage' do
    context 'when user is unauthorized' do
      before do
        post "/api/v1/trains/#{train.id}/add_carriage", params: {
          carriage_id: carriage.id
        }
      end

      it 'returns 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized but error occurs during service work' do
      before do
        login_with_api(user_credentials)
        post "/api/v1/trains/#{train.id}/add_carriage",
             params: {
               carriage_id: carriage_with_train.id
             },
             headers: {
               Authorization: "Bearer #{json_response['access_token']}"
             }
      end

      it 'returns 422 and contains error message' do
        expect(response).to have_http_status(422)
        expect(json_response['message']).to eq('Something went wrong')
        expect(json_response['errors']).to include("Carriage already in train")
      end
    end

    context 'when user is authorized and no errors occurs during service work' do
      before do
        login_with_api(user_credentials)
        post "/api/v1/trains/#{train.id}/add_carriage",
             params: {
               carriage_id: carriage.id
             },
             headers: {
               Authorization: "Bearer #{json_response['access_token']}"
             }
      end

      it 'returns 200 and added carriage' do
        expect(response).to have_http_status(200)
        expect(json_response['message']).to eq('Carriage was successfully added to train')
        expect(json_response['carriage']['train_id']).to eq(train.id)
        expect(train.carriages.pluck(:id)).to include(carriage.id)
      end
    end
  end

  describe '#remove_carriage' do
    context 'when user is unauthorized' do
      before do
        carriage_id = train_with_carriages.carriages.first.id
        delete "/api/v1/trains/#{train_with_carriages.id}/remove_carriage/#{carriage_id}"
      end

      it 'returns 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized but error occurs during service work' do
      before do
        carriage_id = train_with_carriages.carriages.first.id
        login_with_api(user_credentials)
        delete "/api/v1/trains/#{train.id}/remove_carriage/#{carriage_id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 422 and error message' do
        expect(response).to have_http_status(422)
        expect(json_response['message']).to eq('Something went wrong')
        expect(json_response['errors']).to include("Can't remove carriage from different train")
      end
    end

    context 'when user is authorized and no errors occurs during service work' do
      before do
        @carriage_id = train_with_carriages.carriages.first.id
        login_with_api(user_credentials)
        delete "/api/v1/trains/#{train_with_carriages.id}/remove_carriage/#{@carriage_id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 200 and removes carriage from train' do
        expect(response).to have_http_status(200)
        expect(json_response['message']).to eq('Carriage was successfully removed from train')
        expect(train_with_carriages.reload.carriages.pluck(:id)).to_not include(@carriage_id)
      end
    end
  end

  describe '#destroy' do
    context 'when user is unauthorized' do
      before do
        delete "/api/v1/trains/#{train.id}"
      end

      it 'returns 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authorized' do
      before do
        login_with_api(user_credentials)
        delete "/api/v1/trains/#{train.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 204 and destroys train' do
        expect(response).to have_http_status(204)
        expect { train.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
