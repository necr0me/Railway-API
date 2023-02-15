require 'swagger_helper'

RSpec.describe 'api/v1/stations', type: :request do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }
  let(:station) { create(:station) }

  path '/api/v1/stations' do
    get 'Gets all stations. By necr0me' do
      tags 'Stations'
      produces 'application/json'
      parameter name: :station, in: :query, type: :string, required: false,
                description: 'Name of station or first N letters of station name'

      response '200', 'Stations found (From query "?station=Mo")' do
        let(:station) { 'Mo' }
        before { create_list(:station, 3, :station_sequence_with_three_stations) }

        include_context 'with integration test'
      end
    end

    post 'Create a new station. By necr0me' do
      tags 'Stations'
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: :name
      }
      produces 'application/json'
      security [Bearer: {}]

      response '201', 'Station created' do
        let(:params) { attributes_for(:station) }

        include_context 'with integration test'
      end

      response '401', 'You are unauthorized' do
        let(:params) { attributes_for(:station) }
        let(:Authorization) { 'invalid' }

        include_context 'with integration test'
      end

      response '403', 'You are forbidden to perform this action' do
        let(:params) { attributes_for(:station) }
        let(:user) { create(:user) }

        include_context 'with integration test'
      end

      response '422', 'Errors during station creation' do
        let(:params) { { station: { name: '1' } } }

        include_context 'with integration test'
      end
    end

    path '/api/v1/stations/{id}' do
      get 'Get concrete station. By necr0me' do
        tags 'Stations'
        produces 'application/json'
        parameter name: :id, in: :path, type: :string, required: true,
                  description: 'Id of station'

        response '200', 'Station was found' do
          let(:id) { station.id }

          include_context 'with integration test'
        end

        response '404', 'Station not found' do
          let(:id) { -1 }

          include_context 'with integration test'
        end
      end

      put 'Update concrete station. By necr0me' do
        tags 'Stations'
        consumes 'application/json'
        parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
            name: { type: :string }
          },
          required: :name
        }
        parameter name: :id, in: :path, type: :string, required: true,
                  description: 'Id of station'
        produces 'application/json'
        security [Bearer: {}]

        response '200', 'Station updated' do
          let(:id) { station.id }
          let(:params) { { name: 'New name' } }

          include_context 'with integration test'
        end

        response '401', 'You are unauthorized' do
          let(:id) { station.id }
          let(:params) { { name: 'New name' } }
          let(:Authorization) { 'invalid' }

          include_context 'with integration test'
        end

        response '403', 'You are forbidden to perform this action' do
          let(:id) { station.id }
          let(:params) { { name: 'New name' } }
          let(:user) { create(:user) }

          include_context 'with integration test'
        end

        response '404', 'Station not found' do
          let(:id) { -1 }
          let(:params) { { name: 'New name' } }

          include_context 'with integration test'
        end

        response '422', 'Something went wrong during station update' do
          let(:id) { station.id }
          let(:params) { { name: '' } }

          include_context 'with integration test'
        end
      end

      delete 'Delete concrete station. By necr0me' do
        tags 'Stations'
        produces 'application/json'
        parameter name: :id, in: :path, type: :string, required: true,
                  description: 'Id of station'
        security [Bearer: {}]

        response '204', 'Successfully destroyed station' do
          let(:id) { station.id }

          run_test!
        end

        response '401', 'You are unauthorized' do
          let(:Authorization) { 'invalid' }
          let(:id) { station.id }

          include_context 'with integration test'
        end

        response '403', 'You are forbidden to perform this action' do
          let(:user) { create(:user) }
          let(:id) { station.id }

          include_context 'with integration test'
        end

        response '404', 'Station not found' do
          let(:id) { -1 }

          include_context 'with integration test'
        end

        response '422', 'Something went wrong during station destroying' do
          before do
            allow_any_instance_of(Station).to receive(:destroy).and_return(false)
            allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(['Error message'])
          end

          let(:id) { station.id }

          include_context 'with integration test'
        end
      end
    end
  end
end
