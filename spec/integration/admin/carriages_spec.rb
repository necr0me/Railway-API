require "swagger_helper"

RSpec.describe "admin/carriages", type: :request, swagger_doc: "admin/swagger.yaml" do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:carriage_type) { create(:carriage_type) }
  let(:carriage) { create(:carriage) }

  path "/admin/carriages" do
    get "Retrieves all carriages. By necr0me" do
      tags "Carriages"
      produces "application/json"
      security [Bearer: {}]

      response "200", "Carriages found" do
        before { create_list(:carriage, 2) }

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

    post "Creates new carriage. By necr0me" do
      tags "Carriages"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          carriage: {
            type: :object,
            properties: {
              name: { type: :string },
              carriage_type_id: { type: :integer }
            },
            required: %i[name carriage_type_id],
            example: {
              name: "XT-231-321",
              carriage_type_id: 1
            }
          }
        },
        required: %i[carriage]
      }
      produces "application/json"
      security [Bearer: {}]

      let(:params) { { carriage: { name: Faker::Ancient.god, carriage_type_id: carriage_type.id } } }

      response "201", "Carriage successfully created" do
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

      response "422", "Error occurred during carriage create" do
        let(:params) { { carriage: { name: "x", carriage_type: carriage_type.id } } }

        include_context "with integration test"
      end
    end
  end

  path "/admin/carriages/{carriage_id}" do
    let(:carriage_id) { carriage.id }

    put "Update concrete carriage. By necr0me" do
      tags "Carriages"
      consumes "application/json"
      parameter name: :carriage_id, in: :path, type: :integer, required: true,
                description: "Id of carriage that you want to update"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          carriage: {
            type: :object,
            properties: {
              name: { type: :string },
              carriage_type_id: { type: :integer }
            },
            required: %i[name carriage_type_id],
            example: {
              name: "XT-231-321",
              carriage_type_id: 1
            }
          }
        },
        required: %i[carriage]
      }
      produces "application/json"
      security [Bearer: {}]

      let(:params) { { carriage: { name: "New name" } } }

      response "200", "Carriage successfully updated" do
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

      response "404", "Carriage not found" do
        let(:carriage_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during carriage update" do
        let(:params) { { carriage: { name: "x" } } }

        include_context "with integration test"
      end
    end

    delete "Destroy concrete carriage. By necr0me" do
      tags "Carriages"
      parameter name: :carriage_id, in: :path, type: :integer, require: true,
                description: "Id of carriage that you want to destroy"
      produces "application/json"
      security [Bearer: {}]

      response "204", "Carriage successfully destroyed" do
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

      response "404", "Carriage not found" do
        let(:carriage_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during carriage destroy" do
        let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

        before do
          allow(Carriage).to receive(:find).and_return(carriage)
          allow(carriage).to receive(:destroy).and_return(false)
          allow(carriage).to receive(:errors).and_return(errors)
        end

        include_context "with integration test"
      end
    end
  end
end
