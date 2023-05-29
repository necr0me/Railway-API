require "swagger_helper"

RSpec.describe "api/v1/profile", type: :request do
  let(:user) { create(:user, :user_with_profile) }
  let(:profile) { user.profiles.first }
  let(:Authorization) { "Bearer #{access_token}" }

  path "/api/v1/profiles" do
    get "Retrieves user profiles. By necr0me" do
      tags "Profiles"
      produces "application/json"
      security [Bearer: {}]

      response "200", "Profiles found" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are foribdden to perform this action" do
        before { allow(User).to receive(:find).and_return(nil) }

        include_context "with integration test"
      end
    end

    post "Creates user profile. By necr0me" do
      tags "Profiles"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          profile: {
            type: :object,
            properties: {
              name: { type: :string },
              surname: { type: :string },
              patronymic: { type: :string },
              phone_number: { type: :string },
              passport_code: { type: :string }
            },
            required: %i[name surname patronymic phone_number passport_code],
            example:
              {
                name: "John",
                surname: "Doe",
                patronymic: "Doehovich",
                phone_number: "375331234567",
                passport_code: "KH1234567"
              }
          }
        },
        required: %i[profile]
      }
      produces "application/json"
      security [Bearer: {}]

      let(:user) { create(:user) }
      let(:params) { { profile: attributes_for(:profile) } }

      response "201", "Profile successfully created" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "422", "Error occurred during profile create" do
        let(:params) { { profile: { name: "x" } } }

        include_context "with integration test"
      end
    end
  end

  path "/api/v1/profiles/{profile_id}" do
    let(:profile_id) { profile.id }

    put "Updates concrete user profile. By necr0me" do
      tags "Profiles"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          profile: {
            type: :object,
            properties: {
              name: { type: :string },
              surname: { type: :string },
              patronymic: { type: :string },
              phone_number: { type: :string },
              passport_code: { type: :string }
            },
            required: %i[name surname patronymic phone_number passport_code],
            example:
              {
                name: "John",
                surname: "Doe",
                patronymic: "Doehovich",
                phone_number: "375331234567",
                passport_code: "KH1234567"
              }
          }
        },
        required: %i[profile]
      }
      parameter name: :profile_id, in: :path, type: :string, required: true,
                description: "Id of profile that you want to update"
      produces "application/json"
      security [Bearer: {}]

      let(:params) { { profile: { name: "New name" } } }

      response "200", "Profile found" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:other_user) { create(:user, email: "m@m.m") }
        let(:Authorization) { "Bearer #{access_token_for(other_user)}" }
      end

      response "422", "Error occurred during profile update" do
        let(:params) { { profile: { name: "x" } } }

        include_context "with integration test"
      end
    end

    delete "Deletes concrete user profile. By necr0me" do
      tags "Profiles"
      parameter name: :profile_id, in: :path, type: :string, required: true,
                description: "Id of profile that you want to delete"
      produces "application/json"
      security [Bearer: {}]

      response "200", "Profile successfully destroyed" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:other_user) { create(:user, email: "m@m.m") }
        let(:Authorization) { "Bearer #{access_token_for(other_user)}" }

        include_context "with integration test"
      end

      response "422", "Error occurred during profile destroy" do
        before do
          allow(Profile).to receive(:find).and_return(profile)
          allow(profile).to receive(:destroy).and_return(false)
        end

        include_context "with integration test"
      end
    end
  end
end
