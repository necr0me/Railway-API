require "swagger_helper"

RSpec.describe "admin/users", type: :request, swagger_doc: "admin/swagger.yaml" do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }

  path "/admin/users/{user_id}" do
    let(:other_user) { create(:user, email: "m@m.m") }
    let(:user_id) { other_user.id }

    delete "Destroy user. By necr0me" do
      tags "Registrations"
      parameter name: :user_id, in: :path, type: :integer, required: true,
                description: "Id of user whose account will be destroyed"
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
        let(:user) { create(:user, role: :moderator) }

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
          allow(User).to receive(:find)
            .with(other_user.id)
            .and_return(other_user)
          allow(other_user).to receive(:destroy).and_return(false)
          allow(other_user).to receive(:errors).and_return(errors)
        end

        include_context "with integration test"
      end
    end
  end
end
