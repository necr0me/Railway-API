RSpec.describe "Api::V1::PassingTrains", type: :request do
  let(:user) { create(:user, role: :admin) }

  let(:station) { create(:station) }
  let(:train) { create(:train) }

  let(:passing_train) { create(:passing_train) }

  describe "#index" do
    before do
      create(:train, :train_with_stops)
      get "/api/v1/passing_trains"
    end

    it "returns 200 and list of passing train entities" do
      expect(response).to have_http_status(:ok)
      expect(json_response[:passing_trains].size).to eq(PassingTrain.count)
    end
  end

  describe "#create" do
    context "when user is unauthorized" do
      before do
        post "/api/v1/passing_trains",
             params: {
               passing_train: {
                 way_number: 1
               }
             }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized but params are invalid" do
      before do
        post "/api/v1/passing_trains",
             headers: auth_header,
             params: {
               passing_train: attributes_for(:passing_train)
             }
      end

      it "returns 422 and list of errors" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
        expect(json_response[:errors].size).to be > 0
      end
    end

    context "when user is authorized and params are valid" do
      before do
        post "/api/v1/passing_trains",
             headers: auth_header,
             params: {
               passing_train: {
                 arrival_time: DateTime.now,
                 departure_time: DateTime.now + 20.minutes,
                 way_number: 1,
                 station_id: station.id,
                 train_id: train.id
               }
             }
      end

      it "returns 201 and created passing train entity" do
        expect(response).to have_http_status(:created)
        expect(json_response[:passing_train][:id]).to eq(PassingTrain.last.id)
      end
    end
  end

  describe "#update" do
    context "when user is unauthorized" do
      before do
        patch "/api/v1/passing_trains/#{passing_train.id}",
              params: {
                passing_train: {
                  departure_time: DateTime.now + 1.hour
                }
              }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized but params are invalid" do
      before do
        patch "/api/v1/passing_trains/#{passing_train.id}",
              headers: auth_header,
              params: {
                passing_train: {
                  departure_time: DateTime.now - 1.hour
                }
              }
      end

      it "returns 422 and errors list" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
        expect(json_response[:errors].size).to be > 0
      end
    end

    context "when user is authorized and params are valid" do
      before do
        patch "/api/v1/passing_trains/#{passing_train.id}",
              headers: auth_header,
              params: {
                passing_train: {
                  departure_time: DateTime.now + 1.hour
                }
              }
      end

      it "returns 200 and updated passing train" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:passing_train][:id]).to eq(PassingTrain.last.id)
      end
    end
  end

  describe "#destroy" do
    context "when user is unauthorized" do
      before do
        delete "/api/v1/passing_trains/#{passing_train.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized but error occurred during destroy" do
      before do
        allow_any_instance_of(PassingTrain).to receive(:destroy).and_return(false)
        allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(["Error message"])
        delete "/api/v1/passing_trains/#{passing_train.id}",
               headers: auth_header
      end

      it "returns 422 and list of errors, and does not destroys passing train" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
        expect(json_response[:errors].size).to be > 0
      end
    end

    context "when user is authorized and no error occurred during destroy" do
      before do
        delete "/api/v1/passing_trains/#{passing_train.id}",
               headers: auth_header
      end

      it "returns 200 and destroys passing train" do
        expect(response).to have_http_status(:ok)

        expect { passing_train.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
