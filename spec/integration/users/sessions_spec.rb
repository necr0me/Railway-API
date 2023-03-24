require "swagger_helper"

RSpec.describe "users", type: :request do
  # TODO: add description to ALL methods
  path "/users/login" do
    post "Authenticates user. By necr0me" do
      tags "Authentication"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string }
            },
            required: %i[email password],
            example: {
              email: "mail@gmail.com",
              password: "p4$$w0rD"
            }
          }
        },
        required: %i[user]
      }
      produces "application/json"

      before { create(:user) }

      let(:params) { { user: attributes_for(:user) } }

      response "201", "Authenticated successfully" do
        include_context "with integration test"
      end

      response "400", "Error occurred during authentication" do
        let(:params) { { user: { email: "", password: "" } } }

        include_context "with integration test"
      end
    end
  end

  path "/users/refresh_tokens" do
    get "Refreshes access and refresh tokens. By necr0me" do
      tags "Authentication"
      produces "application/json"

      let(:user) { create(:user, :user_with_real_refresh_token) }

      response "200", "Tokens successfully updated" do
        before { cookies["refresh_token"] = user.refresh_token.value }

        include_context "with integration test"
      end

      response "401", "Error occurred during tokens update" do
        include_context "with integration test"
      end
    end
  end

  path "/users/logout" do
    delete "Logouts user. By necr0me" do
      tags "Authentication"
      parameter name: :Authorization, in: :header, type: :string, required: true,
                description: "Authorization header of user that logout. Header looks like this: 'Bearer <access-token>'"
      produces "application/json"
      security [Bearer: {}]

      response "200", "Successful logout" do
        let(:user) { create(:user, :user_with_refresh_token) }
        let(:Authorization) { "Bearer #{access_token}" }

        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end
    end
  end
end
