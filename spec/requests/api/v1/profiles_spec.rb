require 'rails_helper'

RSpec.describe Api::V1::ProfilesController, type: :request do

  let(:user) { create(:user, :user_with_profile) }
  let(:user_credentials) { user; attributes_for(:user) }

  let(:user_without_profile) { create(:user) }
  let(:user_without_profile_credentials) { user_without_profile; attributes_for(:user) }

  describe '#show' do
    context 'when user is unauthorized' do
      before do
        get '/api/v1/profile'
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end


    context 'when user is authorized' do
      before do
        login_with_api(user_credentials)
        get '/api/v1/profile', headers: auth_header
      end

      it 'returns 200 and proper profile' do
        expect(response.status).to eq(200)
        expect(json_response['user_id']).to eq(user.id)
      end
    end
  end

  describe '#create' do
    context 'when user is unauthorized' do
      before do
        post '/api/v1/profile', params: {
          profile: attributes_for(:profile)
        }
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user authorized and tries to create profile with invalid data' do
      before do
        login_with_api(user_without_profile_credentials)
        post '/api/v1/profile',
             params: {
               profile: {
                 name: 'x',
                 surname: 'x',
                 patronymic: 'x',
                 phone_number: 'x',
                 passport_code: 'x'
               }
             },
             headers: auth_header
      end

      it 'returns 400 and error messages' do
        expect(response.status).to eq(422)
        expect(json_response['errors']).to_not be_nil
      end
    end

    context 'when user is authorized and his profile already exists' do
      before do
        login_with_api(user_credentials)
        post '/api/v1/profile',
             params: {
               profile: attributes_for(:profile)
             },
             headers: auth_header
      end

      it 'returns 422 and error message' do
        expect(response.status).to eq(422)
        expect(json_response['message']).to eq('Seems like record with this data already exists')
      end
    end

    context 'when user is authorized and tries to create profile with valid data' do
      before do
        login_with_api(user_without_profile_credentials)
        post '/api/v1/profile',
             params: {
               profile: attributes_for(:profile)
             },
             headers: auth_header
      end

      it 'returns 201 and creates profile' do
        expect(response.status).to eq(201)
        expect(user_without_profile.reload.profile).to_not be_nil
        expect(Profile.last.user_id).to eq(user_without_profile.id)
      end
    end
  end

  describe '#update' do
    context 'when user is unauthorized' do
      before do
        patch '/api/v1/profile', params: {
          profile: attributes_for(:profile)
        }
      end

      it 'returns 401' do
        expect(response.status).to eq(401)
      end
    end

    context 'when user is authorized and tries to update with invalid data' do
      before do
        login_with_api(user_credentials)
        patch '/api/v1/profile',
              params: {
                profile: {
                  name: 'x'
                }
              },
              headers: auth_header
      end

      it 'returns 422 and error messages' do
        expect(response.status).to eq(422)
        expect(json_response['errors']).to_not be_nil
        expect(json_response['errors']).to include(/Name is too short/)
      end
    end

    context 'when user is authorized and tries to update with valid data' do
      before do
        login_with_api(user_credentials)
        patch '/api/v1/profile',
              params: {
                profile: {
                  name: 'Bogdan',
                  surname: 'Choma'
                }
              },
              headers: auth_header
      end

      it 'returns 200 and updates user profile' do
        expect(response.status).to eq(200)
        expect(user.profile.name).to eq('Bogdan')
        expect(user.profile.surname).to eq('Choma')
      end
    end
  end
end