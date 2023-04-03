require "swagger_helper"

RSpec.describe "api/v1/users", type: :request do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }

  path "/api/v1/users/{user_id}" do
    let(:user_id) { user.id }

    get "Retrieves concrete user. By necr0me" do
      tags "Users"
      parameter name: :user_id, in: :path, type: :integer, required: true,
                description: "Id of user that you want to see"
      produces "application/json"
      security [Bearer: {}]

      response "200", "User found" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:another_user) { create(:user, email: "milo@mail.com") }
        let(:Authorization) { "Bearer #{access_token_for(another_user)}" }

        include_context "with integration test"
      end
    end

    put "Updates user password. By necr0me" do
      tags "Users"
      consumes "application/json"
      parameter name: :user_id, in: :path, type: :integer, required: true,
                description: "Id of user that updates password (ANY user can update only his own password)"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              password: { type: :string }
            },
            required: %i[password],
            example: {
              password: "p4$$w0rD"
            }
          }
        },
        required: %i[user]
      }
      produces "application/json"
      security [Bearer: {}]

      let(:params) { { user: { password: "password" } } }

      response "200", "User found" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:another_user) { create(:user, email: "milo@mail.com") }
        let(:Authorization) { "Bearer #{access_token_for(another_user)}" }

        include_context "with integration test"
      end

      response "422", "Error occurred during update" do
        let(:params) { { user: { password: "" } } }

        include_context "with integration test"
      end
    end
  end
end
