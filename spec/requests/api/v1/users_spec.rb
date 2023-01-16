require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:user) { create(:user) }
  let(:user_credentials) { user; attributes_for(:user) }

  describe 'concerns' do
    context 'UserFindable' do
      it 'includes UserFindable concern' do
        expect(described_class.ancestors).to include(UserFindable)
      end
    end
  end

  describe '#show' do
    context 'when user is unauthorized' do
      before do
        get "/api/v1/users/#{user.id}"
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user does not exists' do
      before do
        login_with_api(user_credentials)
        get "/api/v1/users/0", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 404' do
        expect(response.status).to eq(404)
      end

      it 'contains message that cant find user with such id' do
        expect(json_response['message']).to eq("Couldn't find User with 'id'=0")
      end
    end

    context 'when user is authorized and user is correct' do
      before do
        login_with_api(user_credentials)
        get "/api/v1/users/#{user.id}", headers: {
          Authorization: "Bearer #{json_response['access_token']}"
        }
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'returns correct user' do
        expect(json_response['user']['id']).to eq(user.id)
        expect(json_response['user']['email']).to eq(user.email)
      end
    end
  end

  describe '#update' do
    context 'when user is unauthorized' do
      before do
        patch "/api/v1/users/#{user.id}", params: {
          user: attributes_for(:user)
        }
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user does not exists' do
      before do
        login_with_api(user_credentials)
        patch "/api/v1/users/0",
              params: {
                user: attributes_for(:user)
              },
              headers: {
                Authorization: "Bearer #{json_response['access_token']}"
              }
      end

      it 'returns 404' do
        expect(response.status).to eq(404)
      end

      it 'contains error message that cant fund user with such id' do
        expect(json_response['message']).to eq("Couldn't find User with 'id'=0")
      end
    end

    context 'when user tries to update with invalid password' do
      before do
        login_with_api(user_credentials)
        patch "/api/v1/users/#{user.id}",
              params: {
                user: {
                  password: 'x'
                }
              },
              headers: {
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

    context 'when user tries to update with correct data' do
      before do
        login_with_api(user_credentials)
        patch "/api/v1/users/#{user.id}",
              params: {
                user: {
                  password: 'new_password'
                }
              },
              headers: {
                Authorization: "Bearer #{json_response['access_token']}"
              }
      end

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'updates user password' do
        expect(user.reload.authenticate('new_password')).to be_kind_of(User)
      end
    end
  end
end