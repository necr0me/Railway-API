require 'swagger_helper'

RSpec.describe 'api/v1/profile', type: :request do
  let(:user) { create(:user, :user_with_profile) }
  let(:Authorization) { "Bearer #{access_token}" }

  path '/api/v1/profile' do
    get 'Retrieves user profile. By necr0me' do
      tags 'Profile'
      produces 'application/json'
      security [Bearer: {}]

      response '200', 'Profile found' do
        include_context 'with integration test'
      end

      response '401', 'You are unauthorized' do
        let(:Authorization) { 'invalid' }

        include_context 'with integration test'
      end
    end

    post 'Creates user profile. By necr0me' do
      tags 'Profile'
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          profile: {
            type: :object,
            properties: {
              name: { type: :string },
              surname: { type: :string },
              patronymic: { type: :string },
              phone_number: { type: :string },
              passport_code: { type: :string }
            },
            required: %i[name surname patronymic phone_number passport_code]
          }
        },
        required: %i[profile]
      }
      produces 'application/json'
      security [Bearer: {}]

      let(:user) { create(:user) }
      let(:params) { { profile: attributes_for(:profile) } }

      response '201', 'Profile successfully created' do
        include_context 'with integration test'
      end

      response '401', 'You are unauthorized' do
        let(:Authorization) { 'invalid' }

        include_context 'with integration test'
      end

      response '422', 'Error occurred during profile create' do
        let(:params) { { profile: { name: 'x' } } }

        include_context 'with integration test'
      end
    end

    put 'Updates user profile. By necr0me' do
      tags 'Profile'
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          profile: {
            type: :object,
            properties: {
              name: { type: :string },
              surname: { type: :string },
              patronymic: { type: :string },
              phone_number: { type: :string },
              passport_code: { type: :string }
            },
            required: %i[name surname patronymic phone_number passport_code]
          }
        },
        required: %i[profile]
      }
      produces 'application/json'
      security [Bearer: {}]

      let(:params) { { profile: { name: 'New name' } } }

      response '200', 'Profile found' do
        include_context 'with integration test'
      end

      response '401', 'You are unauthorized' do
        let(:Authorization) { 'invalid' }

        include_context 'with integration test'
      end

      response '422', 'Error occurred during profile update' do
        let(:params) { { profile: { name: 'x' } } }

        include_context 'with integration test'
      end
    end
  end
end
