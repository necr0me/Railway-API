require "swagger_helper"

RSpec.describe "api/v1/train_stops", type: :request do
  path "api/v1/train_stops" do
    get "Retrieves all passing trains. By necr0me" do
      tags "Train stops"
      produces "application/json"

      response "200", "Passing trains found" do
        before { create(:train, :train_with_stops) }

        include_context "with integration test"
      end
    end
  end
end
