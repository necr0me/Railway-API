require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do

  let(:user) { build(:user) }
  let(:existing_user) { create(:user) }

  describe '#create' do
    context 'user tries to register with blank data' do
      before do
        post '/users/sign_up',
             params: {
               user: {
                 email: ' ',
                 password: ' '
               }
             }
      end

      it 'returns 422' do
        expect(response.status).to eq(422)
      end

      it 'contains error messages' do
        expect(json_response['errors']).to include(/Password can't be blank/)
        expect(json_response['errors']).to include(/Email can't be blank/)
      end
    end

    context 'user tries to register with already taken email' do
      before do
        post '/users/sign_up',
             params: {
               user: {
                 email: existing_user.email,
                 password: existing_user.password
               }
             }
      end

      it 'returns 422' do
        expect(response.status).to eq(422)
      end

      it 'contains error message' do
        expect(json_response['errors']).to include(/Email has already been taken/)
      end
    end

    context 'user tries to register with valid data' do
      before do
        post '/users/sign_up',
             params: {
               user: {
                 email: user.email,
                 password: user.email
               }
             }
      end

      it 'returns 201' do
        expect(response.status).to eq(201)
      end

      it 'creates user in db' do
        expect(User.find_by(email: user.email).email).to eq(user.email)
      end
    end
  end

  describe '#destroy' do
    context 'when user tries to destroy not existing user' do
      before do
        delete '/users/0'
      end

      it 'returns 400' do
        expect(response.status).to eq(400)
      end

      it 'returns error message' do
        expect(json_response['error']).to eq("Couldn't find User with 'id'=0")
      end
    end

    context 'when user tries to destroy existing user' do
      before do
        delete  "/users/#{existing_user.id}"
      end

      it 'returns 204' do
        expect(response).to have_http_status(204)
      end

      it 'deletes user from db' do
        expect { existing_user.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
