require "swagger_helper"

RSpec.describe "admin/v1/trains", type: :request, swagger_doc: "admin/swagger.yaml" do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:train) { create(:train, :train_with_carriages) }

  path "/admin/trains" do
    get "Retrieves all trains. By necr0me" do
      tags "Trains"
      produces "application/json"
      security [Bearer: {}]

      response "200", "Trains found" do
        before { create_list(:train, 2) }

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
    end

    post "Creates new empty train. By necr0me" do
      tags "Trains"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          train: {
            type: :object,
            properties: {
              route_id: { type: :integer }
            },
            required: %i[route_id],
            example: {
              route_id: 1
            }
          }
        },
        required: %i[train]
      }
      produces "application/json"
      security [Bearer: {}]

      let(:params) { { train: { route_id: create(:route).id } } }

      response "201", "Train successfully created" do
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

      response "422", "Error occurred during train create" do
        let(:params) { { train: { route_id: -1 } } }

        include_context "with integration test"
      end
    end
  end

  path "/admin/trains/{train_id}" do
    let(:train_id) { train.id }

    put "Update concrete train. By necr0me" do
      tags "Trains"
      consumes "application/json"
      parameter name: :train_id, in: :path, type: :integer, required: true,
                description: "Id of train that you want to update"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          train: {
            type: :object,
            properties: {
              route_id: { type: :integer }
            },
            required: %i[route_id],
            example: {
              route_id: 1
            }
          }
        },
        required: %i[train]
      }
      produces "application/json"
      security [Bearer: {}]

      let(:params) { { train: { route_id: create(:route).id } } }

      response "200", "Train successfully updated" do
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

      response "404", "Train not found" do
        let(:train_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during train update" do
        let(:params) { { train: { route_id: -1 } } }

        include_context "with integration test"
      end
    end

    delete "Destroy concrete train. By necr0me" do
      tags "Trains"
      parameter name: :train_id, in: :path, type: :integer, required: true,
                description: "Id of train that you want to update"
      produces "application/json"
      security [Bearer: {}]

      response "204", "Train successfully destroyed" do
        run_test!
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:user) { create(:user) }

        include_context "with integration test"
      end

      response "404", "Train not found" do
        let(:train_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during adding carriage to train" do
        before do
          allow_any_instance_of(Train).to receive(:destroy).and_return(false)
          allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(["Error message"])
        end

        include_context "with integration test"
      end
    end
  end

  path "/admin/trains/{train_id}/add_carriage" do
    let(:train_id) { create(:train).id }

    post "Add concrete carriage to train. By necr0me" do
      tags "Trains"
      consumes "application/json"
      parameter name: :train_id, in: :path, type: :integer, required: true,
                description: "Id of train which to you want add carriage"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          carriage_id: { type: :integer }
        },
        required: %i[carriage_id],
        example: {
          carriage_id: 1
        }
      }
      produces "application/json"
      security [Bearer: {}]

      let(:params) { { carriage_id: create(:carriage).id } }

      response "200", "Carriage successfully added to train" do
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

      response "404", "Train not found" do
        let(:train_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during adding carriage to train" do
        let(:params) { { carriage_id: -1 } }

        include_context "with integration test"
      end
    end
  end

  path "/admin/trains/{train_id}/remove_carriage/{carriage_id}" do
    let(:train_id) { train.id }
    let(:carriage_id) { train.carriages.first.id }

    delete "Remove concrete carriage from train. By necr0me" do
      tags "Trains"
      parameter name: :train_id, in: :path, type: :integer, required: true,
                description: "Id of train which from you want to remove carriage"
      parameter name: :carriage_id, in: :path, type: :integer, required: true,
                description: "Id of carriage which you want to remove from train"
      produces "application/json"
      security [Bearer: {}]

      response "200", "Carriage successfully removed from train" do
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

      response "404", "Train not found" do
        let(:train_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during removing carriage from train" do
        let(:carriage_id) { create(:carriage).id }

        include_context "with integration test"
      end
    end
  end
end
