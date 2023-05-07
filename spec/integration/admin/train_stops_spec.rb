require "swagger_helper"

RSpec.describe "admin/train_stops", type: :request, swagger_doc: "admin/swagger.yaml" do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:train_stop) { create(:train_stop) }

  path "admin/train_stops" do
    post "Creates new passing train. By necr0me" do
      tags "Passing trains"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          train_stop: {
            type: :object,
            properties: {
              arrival_time: { type: :string, format: :datetime },
              departure_time: { type: :string, format: :datetime },
              way_number: { type: :integer },
              station_id: { type: :integer },
              train_id: { type: :integer }
            },
            required: %i[arrival_time departure_time station_id train_id],
            example: {
              arrival_time: DateTime.now,
              departure_time: DateTime.now + 20.minutes,
              way_number: 1,
              station_id: 1,
              train_id: 1
            }
          },
          required: %i[train_stop]
        }
      }
      produces "application/json"
      security [Bearer: {}]

      let(:station) { create(:station) }
      let(:train) { create(:train) }

      let(:params) do
        {
          train_stop: {
            arrival_time: DateTime.now,
            departure_time: DateTime.now + 20.minutes,
            way_number: 1,
            station_id: station.id,
            train_id: train.id
          }
        }
      end

      response "201", "Passing train successfully created" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:user) { create(:user) }

        include_context "with integration test"
      end

      response "422", "Error occurred during passing train create" do
        let(:params) { { train_stop: attributes_for(:train_stop) } }

        include_context "with integration test"
      end
    end
  end

  path "admin/train_stops/{train_stop_id}" do
    let(:train_stop_id) { train_stop.id }

    put "Updates passing train. By necr0me" do
      tags "Passing trains"
      consumes "application/json"
      parameter name: :train_stop_id, in: :path, type: :integer, required: true,
                description: "Id of passing train record that you want to update"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          train_stop: {
            type: :object,
            properties: {
              arrival_time: { type: :string, format: :datetime },
              departure_time: { type: :string, format: :datetime },
              way_number: { type: :integer },
              station_id: { type: :integer },
              train_id: { type: :integer }
            },
            required: %i[arrival_time departure_time station_id train_id],
            example: {
              arrival_time: DateTime.now,
              departure_time: DateTime.now + 20.minutes,
              way_number: 1,
              station_id: 1,
              train_id: 1
            }
          },
          required: %i[train_stop]
        }
      }
      produces "application/json"
      security [Bearer: {}]

      let(:params) { { train_stop: { arrival_time: train_stop.arrival_time + 5.minutes } } }

      response "200", "Passing train successfully updated" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:user) { create(:user) }

        include_context "with integration test"
      end

      response "404", "Passing train not found" do
        let(:train_stop_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during passing train update" do
        let(:params) { { train_stop: { arrival_time: train_stop.departure_time + 5.minutes } } }

        include_context "with integration test"
      end
    end

    delete "Deletes passing train. By necr0me" do
      tags "Passing trains"
      parameter name: :train_stop_id, in: :path, type: :integer, required: true,
                description: "Id of passing train record that you want to destroy"
      produces "application/json"
      security [Bearer: {}]

      response "200", "Passing train successfully destroyed" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:user) { create(:user) }

        include_context "with integration test"
      end

      response "404", "Passing train not found" do
        let(:train_stop_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during passing train destroy" do
        let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

        before do
          allow(TrainStop).to receive(:find).and_return(train_stop)
          allow(train_stop).to receive(:destroy).and_return(false)
          allow(train_stop).to receive(:errors).and_return(errors)
        end

        include_context "with integration test"
      end
    end
  end
end
