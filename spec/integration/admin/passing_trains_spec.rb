require "swagger_helper"

RSpec.describe "admin/passing_trains", type: :request, swagger_doc: "admin/swagger.yaml" do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:passing_train) { create(:passing_train) }

  path "admin/passing_trains" do
    post "Creates new passing train. By necr0me" do
      tags "Passing trains"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          passing_train: {
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
          required: %i[passing_train]
        }
      }
      produces "application/json"
      security [Bearer: {}]

      let(:station) { create(:station) }
      let(:train) { create(:train) }

      let(:params) do
        {
          passing_train: {
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
        let(:params) { { passing_train: attributes_for(:passing_train) } }

        include_context "with integration test"
      end
    end
  end

  path "admin/passing_trains/{passing_train_id}" do
    let(:passing_train_id) { passing_train.id }

    put "Updates passing train. By necr0me" do
      tags "Passing trains"
      consumes "application/json"
      parameter name: :passing_train_id, in: :path, type: :integer, required: true,
                description: "Id of passing train record that you want to update"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          passing_train: {
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
          required: %i[passing_train]
        }
      }
      produces "application/json"
      security [Bearer: {}]

      let(:params) { { passing_train: { arrival_time: passing_train.arrival_time + 5.minutes } } }

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
        let(:passing_train_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during passing train update" do
        let(:params) { { passing_train: { arrival_time: passing_train.departure_time + 5.minutes } } }

        include_context "with integration test"
      end
    end

    delete "Deletes passing train. By necr0me" do
      tags "Passing trains"
      parameter name: :passing_train_id, in: :path, type: :integer, required: true,
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
        let(:passing_train_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during passing train destroy" do
        let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

        before do
          allow(TrainStop).to receive(:find).and_return(passing_train)
          allow(passing_train).to receive(:destroy).and_return(false)
          allow(passing_train).to receive(:errors).and_return(errors)
        end

        include_context "with integration test"
      end
    end
  end
end
