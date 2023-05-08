RSpec.describe "Admin::TrainStops", type: :request do
  let(:user) { create(:user, role: :admin) }

  let(:station) { create(:station) }
  let(:train) { create(:train) }

  let(:train_stop) { create(:train_stop) }

  describe "#create" do
    context "when user is unauthorized" do
      before do
        post "/admin/train_stops",
             params: {
               train_stop: {
                 way_number: 1
               }
             }
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized but params are invalid" do
      before do
        post "/admin/train_stops",
             headers: auth_header,
             params: {
               train_stop: attributes_for(:train_stop)
             }
      end

      it "returns UNPROCESSABLE_ENTITY and list of errors" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
        expect(json_response[:errors].size).to be > 0
      end
    end

    context "when user is authorized and params are valid" do
      before do
        post "/admin/train_stops",
             headers: auth_header,
             params: {
               train_stop: {
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
        expect(json_response[:train_stop][:data][:id].to_i).to eq(TrainStop.last.id)
      end
    end
  end

  describe "#update" do
    context "when user is unauthorized" do
      before do
        patch "/admin/train_stops/#{train_stop.id}",
              params: {
                train_stop: {
                  departure_time: DateTime.now + 1.hour
                }
              }
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized but params are invalid" do
      before do
        patch "/admin/train_stops/#{train_stop.id}",
              headers: auth_header,
              params: {
                train_stop: {
                  departure_time: DateTime.now - 1.hour
                }
              }
      end

      it "returns UNPROCESSABLE_ENTITY and errors list" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
        expect(json_response[:errors].size).to be > 0
      end
    end

    context "when user is authorized and params are valid" do
      before do
        patch "/admin/train_stops/#{train_stop.id}",
              headers: auth_header,
              params: {
                train_stop: {
                  departure_time: DateTime.now + 1.hour
                }
              }
      end

      it "returns OK and updated passing train" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:train_stop][:data][:id].to_i).to eq(TrainStop.last.id)
      end
    end
  end

  describe "#destroy" do
    context "when user is unauthorized" do
      before do
        delete "/admin/train_stops/#{train_stop.id}"
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized but error occurred during destroy" do
      let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

      before do
        allow(TrainStop).to receive(:find).and_return(train_stop)
        allow(train_stop).to receive(:destroy).and_return(false)
        allow(train_stop).to receive(:errors).and_return(errors)

        delete "/admin/train_stops/#{train_stop.id}",
               headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and list of errors, and does not destroys passing train" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
        expect(json_response[:errors].size).to be > 0
      end
    end

    context "when user is authorized and no error occurred during destroy" do
      before do
        delete "/admin/train_stops/#{train_stop.id}",
               headers: auth_header
      end

      it "returns OK and destroys passing train" do
        expect(response).to have_http_status(:ok)

        expect { train_stop.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
