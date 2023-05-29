require "swagger_helper"

RSpec.describe "api/v1/carriages", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:carriage) { create(:carriage) }

  path "/api/v1/carriages/{carriage_id}" do
    let(:carriage_id) { carriage.id }

    get "Get concrete carriage. By necr0me" do
      tags "Carriages"
      parameter name: :carriage_id, in: :path, type: :integer, required: true,
                description: "Id of carriage that you want to see"
      produces "application/json"
      security [Bearer: {}]

      response "200", "Carriage found" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "404", "Carriage not found" do
        let(:carriage_id) { -1 }

        include_context "with integration test"
      end
    end
  end
end
