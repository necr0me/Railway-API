require "swagger_helper"

RSpec.describe "users", type: :request do
  path "/users/sign_up" do
    post "Register new user. By necr0me" do
      tags "Registrations"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              unconfirmed_email: { type: :string },
              password: { type: :string }
            },
            required: %i[unconfirmed_email password],
            example: {
              unconfirmed_email: "mail@gmail.com",
              password: "p4$$w0rD"
            }
          }
        },
        required: %i[user]
      }
      produces "application/json"

      response "201", "User successfully created" do
        let(:params) { { user: attributes_for(:unactivated_user) } }

        include_context "with integration test"
      end

      response "422", "Error occurred during user registration" do
        let(:params) { { user: { unconfirmed_email: "", password: "" } } }

        include_context "with integration test"
      end
    end
  end

  path "/users/{user_id}" do
    let(:user) { create(:user) }
    let(:user_id) { user.id }
    let(:Authorization) { "Bearer #{access_token}" }

    delete "Destroy user. By necr0me" do
      tags "Registrations"
      parameter name: :user_id, in: :path, type: :integer, required: true,
                description: "Id of user that destroys account (user can destroy only own account unless role is admin)"
      produces "application/json"
      security [Bearer: {}]

      response "204", "User successfully destroyed" do
        run_test!
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:user_id) { create(:user, email: "milo@mail.com").id }

        include_context "with integration test"
      end

      response "404", "User not found" do
        let(:user_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during user destroy" do
        let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

        before do
          allow(User).to receive(:find)
            .with(user.id)
            .and_return(user)
          allow(user).to receive(:destroy).and_return(false)
          allow(user).to receive(:errors).and_return(errors)
        end

        include_context "with integration test"
      end
    end
  end
end
