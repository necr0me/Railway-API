require 'swagger_helper'

RSpec.describe 'api/v1/carriages', type: :request do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:carriage_type) { create(:carriage_type) }
  let(:carriage) { create(:carriage) }

  path '/api/v1/carriages' do
    get 'Retrieves all carriages. By necr0me' do
      tags 'Carriages'
      produces 'application/json'
      security [Bearer: {}]

      response '200', 'Carriages found' do
        before { create_list(:carriage, 2) }

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

    post 'Creates new carriage. By necr0me' do
      tags 'Carriages'
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          carriage_type_id: { type: :integer }
        },
        required: %i[name carriage_type_id]
      }
      produces 'application/json'
      security [Bearer: {}]

      let(:params) { { name: Faker::Ancient.god, carriage_type_id: carriage_type.id } }

      response '201', 'Carriage successfully created' do
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

      response '422', 'Error occurred during carriage create' do
        let(:params) { { name: 'x', carriage_type: carriage_type.id } }

        include_context 'with integration test'
      end
    end
  end

  path '/api/v1/carriages/{carriage_id}' do
    let(:carriage_id) { carriage.id }

    get 'Get concrete carriage. By necr0me' do
      tags 'Carriages'
      parameter name: :carriage_id, in: :path, type: :string, required: true,
                description: 'Id of carriage that you want to see'
      produces 'application/json'
      security [Bearer: {}]

      response '200', 'Carriage found' do
        include_context 'with integration test'
      end

      response '401', 'You are unauthorized' do
        let(:Authorization) { 'invalid' }

        include_context 'with integration test'
      end

      response '404', 'Carriage not found' do
        let(:carriage_id) { -1 }

        include_context 'with integration test'
      end
    end

    put 'Update concrete carriage. By necr0me' do
      tags 'Carriages'
      consumes 'application/json'
      parameter name: :carriage_id, in: :path, type: :string, required: true,
                description: 'Id of carriage that you want to update'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          carriage_type_id: { type: :integer }
        },
        required: %i[name carriage_type_id]
      }
      produces 'application/json'
      security [Bearer: {}]

      let(:params) { { name: 'New name' } }

      response '200', 'Carriage successfully updated' do
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

      response '404', 'Carriage not found' do
        let(:carriage_id) { -1 }

        include_context 'with integration test'
      end

      response '422', 'Error occurred during carriage update' do
        let(:params) { { name: 'x' } }

        include_context 'with integration test'
      end
    end

    delete 'Destroy concrete carriage. By necr0me' do
      tags 'Carriages'
      parameter name: :carriage_id, in: :path, type: :string, require: true,
                description: 'Id of carriage that you want to destroy'
      produces 'application/json'
      security [Bearer: {}]

      response '204', 'Carriage successfully destroyed' do
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

      response '404', 'Carriage not found' do
        let(:carriage_id) { -1 }

        include_context 'with integration test'
      end

      response '422', 'Error occurred during carriage destroy' do
        before do
          allow_any_instance_of(Carriage).to receive(:destroy).and_return(false)
          allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(['Error message'])
        end

        include_context 'with integration test'
      end
    end
  end
end

