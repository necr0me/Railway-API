require "swagger_helper"

RSpec.describe "api/v1/trains", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:train) { create(:train, :train_with_carriages) }

  path "/api/v1/trains/{train_id}" do
    let(:train_id) { train.id }

    get "Show concrete train. By necr0me" do
      tags "Trains"
      parameter name: :train_id, in: :path, type: :integer, required: true,
                description: "Id of train that you want to see"
      produces "application/json"
      security [Bearer: {}]

      response "200", "Train found" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:train_policy) { instance_double(TrainPolicy) }

        before do
          allow(TrainPolicy).to receive(:new).and_return(train_policy)
          allow(train_policy).to receive(:show?).and_return(false)
        end

        include_context "with integration test"
      end

      response "404", "Train not found" do
        let(:train_id) { -1 }

        include_context "with integration test"
      end
    end
  end

  path "/api/v1/trains/{train_id}/stops" do
    let(:train_id) { train.id }

    get "Get train and its stops. By necr0me" do
      tags "Trains"
      parameter name: :train_id, in: :path, type: :integer, required: true,
                description: "Id of train that you want to see"
      produces "application/json"

      let(:name_list) { %i[Grodno Mosty Volkovysk Baranovici Minsk] }

      let(:stations) { create_list(:station, name_list.count, :station_sequence_with_name_list, list: name_list) }
      let(:route) { create(:route, :route_with_specific_stations, stations: stations, destination: "Grodno - Minsk") }

      let(:train) do
        create(:train, :train_with_specific_stops, route: route, stops_at: stations, start_time: Time.now.utc + 1.hour)
      end

      include_context "with sequence cleaner"

      response "200", "Train and its stops succesfully found" do
        include_context "with integration test"
      end

      response "404", "Train is not found" do
        let(:train_id) { -1 }

        include_context "with integration test"
      end
    end
  end
end
