require 'swagger_helper'

RSpec.describe 'api/v1/carriage_types', type: :request do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:carriage_type) { create(:carriage_type) }

  path '/api/v1/carriage_types' do
    get 'Retrieves all carriage types. By necr0me' do
      tags 'Carriage types'
      produces 'application/json'
      security [Bearer: {}]

      response '200', 'Carriage types found' do
        before { create_list(:carriage_type, 3) }

        include_context 'with integration test'
      end

      response '401', 'You are unauthorized' do
        let(:Authorization) { 'invalid' }

        include_context 'with integration test'
      end

      response '403', 'You are forbidden to perform this action' do
        let(:user) { create(:user) }

        include_context 'with integration test'
      end
    end

    post 'Creates new carriage type. By necr0me' do
      tags 'Carriage types'
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          carriage_type: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              capacity: { type: :integer }
            },
            required: %i[name capacity],
            example: {
              name: 'Coupe',
              description: 'Some description',
              capacity: 32
            }
          }
        },
        required: %i[carriage_type]
      }
      produces 'application/json'
      security [Bearer: {}]

      let(:params) { { carriage_type: attributes_for(:carriage_type) } }

      response '201', 'Carriage type successfully created' do
        include_context 'with integration test'
      end

      response '401', 'You are unauthorized' do
        let(:Authorization) { 'invalid' }

        include_context 'with integration test'
      end

      response '403', 'You are forbidden to perform this action' do
        let(:user) { create(:user) }

        include_context 'with integration test'
      end

      response '422', 'Error occurred during carriage type create' do
        let(:params) { { carriage_type: { name: 'x', description: 'x', capacity: -1 } } }

        include_context 'with integration test'
      end
    end
  end

  path '/api/v1/carriage_types/{carriage_type_id}' do
    let(:carriage_type_id) { carriage_type.id }

    put 'Updates carriage type. By necr0me' do
      tags 'Carriage types'
      consumes 'application/json'
      parameter name: :carriage_type_id, in: :path, type: :integer, required: true,
                description: 'Id of carriage type that you want to update'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          carriage_type: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              capacity: { type: :integer }
            },
            required: %i[name capacity],
            example: {
              name: 'Coupe',
              description: 'Some description',
              capacity: 32
            }
          }
        },
        required: %i[carriage_type]
      }
      produces 'application/json'
      security [Bearer: {}]

      let(:params) { { carriage_type: { name: 'New name', description: 'New description', capacity: 4 } } }

      response '200', 'Carriage type successfully updated' do
        include_context 'with integration test'
      end

      response '401', 'You are unauthorized' do
        let(:Authorization) { 'invalid' }

        include_context 'with integration test'
      end

      response '403', 'You are forbidden to perform this action' do
        let(:user) { create(:user) }

        include_context 'with integration test'
      end

      response '404', 'Carriage type not found' do
        let(:carriage_type_id) { -1 }

        include_context 'with integration test'
      end

      response '422', 'Error occurred during carriage type update' do
        let(:carriage_type) { create(:carriage_type, :type_with_carriage) }

        include_context 'with integration test'
      end
    end

    delete 'Deletes carriage type. By necr0me' do
      tags 'Carriage types'
      parameter name: :carriage_type_id, in: :path, type: :integer, required: true,
                description: 'Id of carriage type that you want to destroy'
      produces 'application/json'
      security [Bearer: {}]

      response '204', 'Carriage type successfully destroyed' do
        run_test!
      end

      response '401', 'You are unauthorized' do
        let(:Authorization) { 'invalid' }

        include_context 'with integration test'
      end

      response '403', 'You are forbidden to perform this action' do
        let(:user) { create(:user) }

        include_context 'with integration test'
      end

      response '404', 'Carriage type not found' do
        let(:carriage_type_id) { -1 }

        include_context 'with integration test'
      end

      response '422', 'Error occurred during carriage type destroy' do
        let(:carriage_type) { create(:carriage_type, :type_with_carriage) }

        include_context 'with integration test'
      end
    end
  end
end
