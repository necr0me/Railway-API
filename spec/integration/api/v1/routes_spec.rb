require 'swagger_helper'

RSpec.describe 'api/v1/routes', type: :request do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:route) { create(:route, :route_with_stations) }

  include_context 'with sequence cleaner'

  path '/api/v1/routes' do
    post 'Creates empty route. By necr0me' do
      tags 'Routes'
      produces 'application/json'
      security [Bearer: {}]

      response '201', 'Route successfully created' do
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

      response '422', 'Error occurred during route creation' do
        before do
          allow_any_instance_of(Route).to receive(:persisted?).and_return(false)
          allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(['Error message'])
        end

        include_context 'with integration test'
      end
    end
  end

  path '/api/v1/routes/{route_id}' do
    let(:route_id) { route.id }

    get 'Find concrete route. By necr0me' do
      tags 'Routes'
      parameter name: :route_id, in: :path, type: :integer, required: true,
                description: 'Id of route'
      produces 'application/json'

      response '200', 'Route found' do
        include_context 'with integration test'
      end

      response '404', 'Route not found' do
        let(:route_id) { -1 }

        include_context 'with integration test'
      end
    end

    delete 'Delete concrete route. By necr0me' do
      tags 'Routes'
      parameter name: :route_id, in: :path, type: :integer, required: true,
                description: 'Id of route'
      produces 'application/json'
      security [Bearer: {}]

      response '204', 'Route successfully destroyed' do
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

      response '404', 'Route not found' do
        let(:route_id) { -1 }

        include_context 'with integration test'
      end

      response '422', 'Error occurred during route destroying' do
        before do
          allow_any_instance_of(Route).to receive(:destroy).and_return(false)
          allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(['Error message'])
        end

        include_context 'with integration test'
      end
    end
  end

  path '/api/v1/routes/{route_id}/add_station' do
    let(:route_id) { route.id }

    post 'Add existing station to existing route. By necr0me' do
      tags 'Routes'
      consumes 'application/json'
      parameter name: :route_id, type: :integer, in: :path, required: true,
                description: 'Id of route which to you want add station'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          station_id: { type: :integer }
        },
        required: %i[station_id],
      }
      produces 'application/json'
      security [Bearer: {}]

      let(:route_id) { route.id }
      let(:params) { { station_id: create(:station).id } }

      response '201', 'Station successfully added to route' do
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

      response '404', 'Route not found' do
        let(:route_id) { -1 }

        include_context 'with integration test'
      end

      response '422', 'Station does not exist' do
        let(:params) { { station_id: -1 } }

        include_context 'with integration test'
      end
    end
  end

  path '/api/v1/routes/{route_id}/remove_station/{station_id}' do
    let(:route_id) { route.id }
    let(:station) { route.stations.first }
    let(:station_id) { station.id }

    delete 'Remove station from route. By necr0me' do
      tags 'Routes'
      parameter name: :route_id, in: :path, type: :integer, required: true,
                description: 'Id of route where from station removing'
      parameter name: :station_id, in: :path, type: :integer, required: true,
                description: 'Id of station that removing from route'
      produces 'application/json'
      security [Bearer: {}]

      response '200', 'Successfully remove station from route' do
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

      response '404', 'Route not found' do
        let(:route_id) { -1 }

        include_context 'with integration test'
      end

      response '422', 'Station already not in route' do
        let(:station_id) { create(:station).id }

        include_context 'with integration test'
      end
    end
  end
end
