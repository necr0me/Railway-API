RSpec.describe "Api::V1::TrainStops", type: :request do
  let(:user) { create(:user) }

  # TODO: test with different options in query params (or it is already tested in service)
  describe "#index" do
    context "when error occurred during service work" do
      let(:service) { instance_double(Trains::FinderService, success?: false, error: "Error message") }

      before do
        allow(Trains::FinderService).to receive(:call).and_return(service)
        create(:train, :train_with_stops)
        get "/api/v1/train_stops"
      end

      it "returns 422 and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to eq("Error message")
      end
    end

    context "when no error occured during service work" do
      before do
        create(:train, :train_with_stops)
        get "/api/v1/train_stops"
      end

      it "returns 200 and list of passing train entities" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:found_trains][:data].size).to eq(TrainStop.count)
      end
    end
  end
end
