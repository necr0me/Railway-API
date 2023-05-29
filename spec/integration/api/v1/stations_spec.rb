require "swagger_helper"

RSpec.describe "api/v1/stations", type: :request do
  let(:user) { create(:user) }

  let(:station) { create(:station) }

  path "/api/v1/stations" do
    get "Gets all stations. By necr0me" do
      tags "Stations"
      produces "application/json"
      parameter name: :station, in: :query, type: :string, required: false,
                description: "Name of station or first N letters of station name"

      # TODO: add more examples
      response "200", 'Stations found (From query "?station=Mo")' do
        let(:station) { "Mo" }

        before { create_list(:station, 3, :station_sequence_with_name_list) }

        include_context "with sequence cleaner"
        include_context "with integration test"
      end
    end
  end

  path "/api/v1/stations/{station_id}" do
    let(:station_id) { station.id }

    get "Get concrete station. By necr0me" do
      tags "Stations"
      produces "application/json"
      parameter name: :station_id, in: :path, type: :string, required: true,
                description: "Id of station"

      response "200", "Station was found" do
        include_context "with integration test"
      end

      response "404", "Station not found" do
        let(:station_id) { -1 }

        include_context "with integration test"
      end
    end
  end
end
