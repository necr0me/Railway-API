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

      # TODO: add more examples
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
          station: {
            type: :object,
            properties: {
              name: { type: :string }
            },
            required: %i[name],
            example: {
              name: 'Melbourne'
            }
          },
        },
        required: %i[station]
      }
      produces 'application/json'
      security [Bearer: {}]

      let(:params) { { station: attributes_for(:station) } }

      response '201', 'Station created' do
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

      response '422', 'Errors during station creation' do
        let(:params) { { station: { name: '1' } } }

        include_context 'with integration test'
      end
    end

    path '/api/v1/stations/{station_id}' do
      let(:station_id) { station.id }

      get 'Get concrete station. By necr0me' do
        tags 'Stations'
        produces 'application/json'
        parameter name: :station_id, in: :path, type: :string, required: true,
                  description: 'Id of station'

        response '200', 'Station was found' do
          include_context 'with integration test'
        end

        response '404', 'Station not found' do
          let(:station_id) { -1 }

          include_context 'with integration test'
        end
      end

      put 'Update concrete station. By necr0me' do
        tags 'Stations'
        consumes 'application/json'
        parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
            station: {
              type: :object,
              properties: {
                name: { type: :string }
              },
              required: %i[name],
              example: {
                name: 'New name'
              }
            }
          },
          required: %i[station]
        }
        parameter name: :station_id, in: :path, type: :integer, required: true,
                  description: 'Id of station'
        produces 'application/json'
        security [Bearer: {}]

        let(:params) { { station: { name: 'New name' } } }

        response '200', 'Station updated' do
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

        response '404', 'Station not found' do
          let(:station_id) { -1 }

          include_context 'with integration test'
        end

        response '422', 'Something went wrong during station update' do
          let(:params) { { station: { name: '' } } }

          include_context 'with integration test'
        end
      end

      delete 'Delete concrete station. By necr0me' do
        tags 'Stations'
        produces 'application/json'
        parameter name: :station_id, in: :path, type: :integer, required: true,
                  description: 'Id of station'
        security [Bearer: {}]

        response '204', 'Successfully destroyed station' do
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

        response '404', 'Station not found' do
          let(:station_id) { -1 }

          include_context 'with integration test'
        end

        response '422', 'Something went wrong during station destroying' do
          before do
            allow_any_instance_of(Station).to receive(:destroy).and_return(false)
            allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(['Error message'])
          end

          include_context 'with integration test'
        end
      end
    end
  end
end
