require "swagger_helper"

RSpec.describe "api/v1/users", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { "Bearer #{access_token}" }

  path "/api/v1/users/" do
    get "Retrieves concrete user. By necr0me" do
      tags "Users"
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
        before { allow(User).to receive(:find).with(user.id).and_return(nil) }

        include_context "with integration test"
      end
    end

    path "/api/v1/users/activate" do
      post "Activates user account. By necr0me" do
        tags "Users"
        consumes "application/json"
        parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
            token: { type: :string }
          },
          required: %i[token],
          example: {
            token: SecureRandom.hex(16)
          }
        }
        produces "application/json"

        let(:user) { create(:unactivated_user) }
        let(:params) { { token: user.confirmation_token } }

        response "200", "Account successfully activated" do
          include_context "with integration test"
        end

        response "422", "Error occurred during activation" do
          let(:params) { { token: "invalid" } }

          include_context "with integration test"
        end
      end

      path "/api/v1/users/reset_email" do
        post "Generates and sends reset email link on current email of authorized user. By necr0me" do
          tags "Users"
          produces "application/json"
          security [Bearer: {}]

          response "200", "Email reset token was successfully generated" do
            include_context "with integration test"
          end

          response "401", "You are unauthorized" do
            let(:Authorization) { "invalid" }

            include_context "with integration test"
          end

          response "403", "You are forbidden to perform this action" do
            before { allow(User).to receive(:find).with(user.id).and_return(nil) }

            include_context "with integration test"
          end

          response "400", "Error occurred during reset email token generation" do
            let(:service) { instance_double(Users::Email::ResetService, success?: false, error: ["Error message"]) }

            before { allow(Users::Email::ResetService).to receive(:call).and_return(service) }

            include_context "with integration test"
          end
        end
      end

      path "/api/v1/users/update_email" do
        patch "Generates and sends activation link on new users email. By necr0me" do
          tags "Users"
          consumes "application/json"
          parameter name: :params, in: :body, schema: {
            type: :object,
            properties: {
              email: { type: :string },
              token: { type: :string }
            },
            required: %i[email token],
            example: {
              email: "new_email@gmail.com",
              token: SecureRandom.hex(16)
            }
          }
          produces "application/json"
          security [Bearer: {}]

          let(:params) { { email: email, token: user.reset_email_token } }

          let(:user) { create(:user, reset_email_token: token, reset_email_sent_at: DateTime.now.utc) }

          let(:email) { "new_email@gmail.com" }
          let(:token) { "token" }

          response "200", "Link successfully generated and sent on new email" do
            include_context "with integration test"
          end

          response "401", "You are unauthorized" do
            let(:Authorization) { "invalid" }

            include_context "with integration test"
          end

          response "403", "You are forbidden to perform this action" do
            before { allow(User).to receive(:find).with(user.id).and_return(nil) }

            include_context "with integration test"
          end

          response "422", "Error occurred during email update" do
            let(:email) { user.email }

            include_context "with integration test"
          end
        end
      end

      path "/api/v1/users/reset_password" do
        post "Generates and sends reset password link on entered by user email. By necr0me" do
          tags "Users"
          consumes "application/json"
          parameter name: :params, in: :body, schema: {
            type: :object,
            properties: {
              email: { type: :string }
            },
            required: %i[email],
            example: {
              email: "johndoe@gmail.com"
            }
          }
          produces "application/json"

          let(:params) { { email: user.email } }

          response "200", "Reset password link was successfully generated and sent" do
            include_context "with integration test"
          end

          response "400", "Error occurred during reset password link generation" do
            let(:params) { { email: "invalid@gmail.com" } }

            include_context "with integration test"
          end
        end
      end

      path "/api/v1/users/update_password" do
        patch "Updates user password. By necr0me" do
          tags "Users"
          consumes "application/json"
          parameter name: :params, in: :body, schema: {
            type: :object,
            properties: {
              password: { type: :string },
              token: { type: :string }
            },
            required: %i[password token],
            example: {
              password: "12345678",
              token: SecureRandom.hex(16)
            }
          }
          produces "application/json"

          let(:params) { { password: password, token: user.reset_password_token } }

          let(:user) { create(:user, reset_password_token: token, reset_password_sent_at: DateTime.now.utc) }

          let(:password) { "12345678" }
          let(:token) { "token" }

          response "200", "User password was successfully updated" do
            include_context "with integration test"
          end

          response "422", "Something went wrong during password update" do
            let(:password) { "" }

            include_context "with integration test"
          end
        end
      end
    end
  end
end
