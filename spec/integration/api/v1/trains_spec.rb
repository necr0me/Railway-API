require "swagger_helper"

RSpec.describe "api/v1/trains", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:train) { create(:train, :train_with_carriages) }

  path "/api/v1/trains/{train_id}" do
    let(:train_id) { train.id }

    get "Show concrete train. By necr0me" do
      tags "Trains"
      parameter name: :train_id, in: :path, type: :integer, required: true,
                description: "Id of train that you want to see"
      produces "application/json"
      security [Bearer: {}]

      response "200", "Train found" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:train_policy) { instance_double(TrainPolicy) }

        before do
          allow(TrainPolicy).to receive(:new).and_return(train_policy)
          allow(train_policy).to receive(:show?).and_return(false)
        end

        include_context "with integration test"
      end

      response "404", "Train not found" do
        let(:train_id) { -1 }

        include_context "with integration test"
      end
    end
  end
end
