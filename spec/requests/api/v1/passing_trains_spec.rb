RSpec.describe "Api::V1::PassingTrains", type: :request do
  let(:user) { create(:user) }

  # TODO: test with different options in query params (or it is already tested in service)
  describe "#index" do
    context "when error occured during service work" do
      before do
        allow_any_instance_of(Trains::FinderService).to receive(:success?).and_return(false)
        allow_any_instance_of(Trains::FinderService).to receive(:error).and_return("Error message")
        create(:train, :train_with_stops)
        get "/api/v1/passing_trains"
      end

      it "returns 422 and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to eq("Error message")
      end
    end

    context "when no error occured during service work" do
      before do
        create(:train, :train_with_stops)
        get "/api/v1/passing_trains"
      end

      it "returns 200 and list of passing train entities" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:found_trains][:data].size).to eq(PassingTrain.count)
      end
    end
  end
end
