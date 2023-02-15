require 'swagger_helper'

RSpec.describe 'api/v1/carriage_types', type: :request do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }

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
          name: { type: :string },
          description: { type: :string },
          capacity: { type: :integer }
        },
        require: %i[name capacity description]
      }
      produces 'application/json'
      security [Bearer: {}]

      response '201', 'Carriage type successfully created' do
        let(:params) { attributes_for(:carriage_type) }

        include_context 'with integration test'
      end

      response '401', 'You are unauthorized' do
        let(:Authorization) { 'invalid' }
        let(:params) { attributes_for(:carriage_type) }

        include_context 'with integration test'
      end

      response '403', 'You are forbiden to perform this action' do
        let(:user) { create(:user) }
        let(:params) { attributes_for(:carriage_type) }

        include_context 'with integration test'
      end

      response '422', 'Error occurred during carriage type create' do
        let(:params) { { name: 'x', description: 'x', capacity: -1 } }

        include_context 'with integration test'
      end
    end
  end

  path '/api/v1/carriage_types/{carriage_type_id}' do
    let(:carriage_type) { create(:carriage_type) }

    put 'Updates carriage type. By necr0me' do
      tags 'Carriage types'
      consumes 'application/json'
      parameter name: :carriage_type_id, in: :path, type: :string, required: true,
                description: 'Id of carriage type that you want to update'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          capacity: { type: :integer }
        },
        require: %i[name capacity description]
      }
      produces 'application/json'
      security [Bearer: {}]

      response '200', 'Carriage type successfully updated' do
        let(:carriage_type_id) { carriage_type.id }
        let(:params) { { name: 'New name', description: 'New description', capacity: 4 } }

        include_context 'with integration test'
      end

      response '401', 'You are unauthorized' do
        let(:Authorization) { 'invalid' }
        let(:carriage_type_id) { carriage_type.id }
        let(:params) { { name: 'New name', description: 'New description', capacity: 4 } }

        include_context 'with integration test'
      end

      response '403', 'You are forbidden to perform this action' do
        let(:user) { create(:user) }
        let(:carriage_type_id) { carriage_type.id }
        let(:params) { { name: 'New name', description: 'New description', capacity: 4 } }

        include_context 'with integration test'
      end

      response '404', 'Carriage type not found' do
        let(:carriage_type_id) { -1 }
        let(:params) { { name: 'New name', description: 'New description', capacity: 4 } }

        include_context 'with integration test'
      end

      response '422', 'Error occurred during carriage type update' do
        let(:carriage_type) { create(:carriage_type, :type_with_carriage) }
        let(:carriage_type_id) { carriage_type.id }
        let(:params) { { name: 'New name', description: 'New description', capacity: 4 } }

        include_context 'with integration test'
      end
    end

    delete 'Deletes carriage type. By necr0me' do
      tags 'Carriage types'
      parameter name: :carriage_type_id, in: :path, type: :string, required: true,
                description: 'Id of carriage type that you want to destroy'
      produces 'application/json'
      security [Bearer: {}]

      response '204', 'Carriage type successfully destroyed' do
        let(:carriage_type_id) { carriage_type.id }

        run_test!
      end

      response '401', 'You are unauthorized' do
        let(:Authorization) { 'invalid' }
        let(:carriage_type_id) { carriage_type.id }

        include_context 'with integration test'
      end

      response '403', 'You are forbidden to perform this action' do
        let(:user) { create(:user) }
        let(:carriage_type_id) { carriage_type.id }

        include_context 'with integration test'
      end

      response '404', 'Carriage type not found' do
        let(:carriage_type_id) { -1 }

        include_context 'with integration test'
      end

      response '422', 'Error occurred during carriage type destroy' do
        let(:carriage_type) { create(:carriage_type, :type_with_carriage) }
        let(:carriage_type_id) { carriage_type.id }

        include_context 'with integration test'
      end
    end
  end
end
