require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do

  let(:user) { create(:user) }

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

    context 'when user is authorized and user is correct' do
      before do
        get "/api/v1/users/#{user.id}", headers: auth_header
      end

      it 'returns 200 and proper user' do
        expect(response.status).to eq(200)

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


    context 'when user tries to update with invalid password' do
      before do
        patch "/api/v1/users/#{user.id}",
              params: {
                user: {
                  password: 'x'
                }
              },
              headers: auth_header
      end

      it 'returns 422 and contains error message' do
        expect(response.status).to eq(422)
        expect(json_response['errors']).to_not be_nil
      end
    end

    context 'when user tries to update with correct data' do
      before do
        patch "/api/v1/users/#{user.id}",
              params: {
                user: {
                  password: 'new_password'
                }
              },
              headers: auth_header
      end

      it 'returns 200 and updates user password' do
        expect(response.status).to eq(200)
        expect(user.reload.authenticate('new_password')).to be_kind_of(User)
      end
    end
  end
end