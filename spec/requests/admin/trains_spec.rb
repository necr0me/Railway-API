RSpec.describe "Admin::Trains", type: :request do
  let(:user) { create(:user, role: :admin) }

  let(:train) { create(:train) }
  let(:train_with_carriages) { create(:train, :train_with_carriages) }

  let(:route) { create(:route) }

  let(:carriage) { create(:carriage) }
  let(:carriage_with_train) { create(:carriage, train_id: train.id) }

  describe "#index" do
    context "when user is unauthorized" do
      before do
        get "/admin/trains"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized" do
      before do
        create_list(:train, 6)
        get "/admin/trains/#{query_param}", headers: auth_header
      end

      context "when query param 'page' is presented" do
        let(:query_param) { "?page=2" }

        it "returns ok, list of 1 train (second page), number of pages equals 2" do
          expect(response).to have_http_status(:ok)

          expect(json_response[:trains][:data].count).to eq(1)
          expect(json_response[:pages]).to eq((Train.count / 5.0).ceil)
        end
      end

      context "when query param 'page' is not presented" do
        let(:query_param) { "" }

        it "returns ok, list of 5 trains (first page), number of pages equals 2" do
          expect(response).to have_http_status(:ok)

          expect(json_response[:trains][:data].count).to eq(5)
          expect(json_response[:pages]).to eq((Train.count / 5.0).ceil)
        end
      end
    end
  end

  describe "#show" do
    context "when user is unauthorized" do
      before do
        get "/admin/trains/#{train.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # TODO: test included
    context "when user is authorized" do
      before do
        get "/admin/trains/#{train.id}", headers: auth_header
      end

      it "returns proper train" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:train][:data][:id].to_i).to eq(train.id)
      end
    end
  end

  describe "#create" do
    context "when user is unauthorized" do
      before do
        post "/admin/trains", params: {
          train: {
            route_id: route.id
          }
        }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and error occurs during creating of train" do
      let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

      before do
        allow(Train).to receive(:create).and_return(train)
        allow(train).to receive(:persisted?).and_return(false)
        allow(train).to receive(:errors).and_return(errors)

        post "/admin/trains", headers: auth_header
      end

      it "returns 422 and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when user is authorized and tries to create train with route" do
      before do
        post "/admin/trains", params: {
          train: {
            route_id: route.id
          }
        }, headers: auth_header
      end

      it "creates train and returns it to user" do
        expect(response).to have_http_status(:created)
        expect(json_response[:message]).to eq("Train was successfully created")
        expect(json_response[:train][:data][:id].to_i).to eq(Train.last.id)
      end
    end
  end

  describe "#update" do
    context "when user is unauthorized" do
      before do
        patch "/admin/trains/#{train.id}", params: {
          train: {
            route_id: route.id
          }
        }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and error occurs during update" do
      let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

      before do
        allow(Train).to receive(:find).and_return(train)
        allow(train).to receive(:update).and_return(false)
        allow(train).to receive(:errors).and_return(errors)

        patch "/admin/trains/#{train.id}", params: {
          train: {
            route_id: route.id
          }
        }, headers: auth_header
      end

      it "returns 422 and errors" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:message]).to eq("Something went wrong")
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when user is authorized and updates with correct data" do
      before do
        patch "/admin/trains/#{train.id}", params: {
          train: {
            route_id: route.id
          }
        }, headers: auth_header
      end

      it "updates train attributes and returns updated train" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq("Train was successfully updated")
        expect(json_response[:train][:route_id]).to eq(route.id)
      end
    end
  end

  describe "#add_carriage" do
    context "when user is unauthorized" do
      before do
        post "/admin/trains/#{train.id}/add_carriage", params: {
          carriage_id: carriage.id
        }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized but error occurs during service work" do
      before do
        post "/admin/trains/#{train.id}/add_carriage",
             params: {
               carriage_id: carriage_with_train.id
             },
             headers: auth_header
      end

      it "returns 422 and contains error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:message]).to eq("Something went wrong")
        expect(json_response[:errors]).to include("Carriage already in train")
      end
    end

    context "when user is authorized and no errors occurs during service work" do
      before do
        post "/admin/trains/#{train.id}/add_carriage",
             params: {
               carriage_id: carriage.id
             },
             headers: auth_header
      end

      it "returns 200 and added carriage" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq("Carriage was successfully added to train")
        expect(json_response[:carriage][:data][:id].to_i).to eq(carriage.id)
        expect(train.carriages.pluck(:id)).to include(carriage.id)
      end
    end
  end

  describe "#remove_carriage" do
    context "when user is unauthorized" do
      before do
        carriage_id = train_with_carriages.carriages.first.id
        delete "/admin/trains/#{train_with_carriages.id}/remove_carriage/#{carriage_id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized but error occurs during service work" do
      before do
        carriage_id = train_with_carriages.carriages.first.id
        delete "/admin/trains/#{train.id}/remove_carriage/#{carriage_id}", headers: auth_header
      end

      it "returns 422 and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:message]).to eq("Something went wrong")
        expect(json_response[:errors]).to include("Can't remove carriage from different train")
      end
    end

    context "when user is authorized and no errors occurs during service work" do
      let(:carriage_id) { train_with_carriages.carriages.first.id }

      before do
        delete "/admin/trains/#{train_with_carriages.id}/remove_carriage/#{carriage_id}", headers: auth_header
      end

      it "returns 200 and removes carriage from train" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq("Carriage was successfully removed from train")
        expect(train_with_carriages.reload.carriages.pluck(:id)).not_to include(carriage_id)
      end
    end
  end

  describe "#destroy" do
    context "when user is unauthorized" do
      before do
        delete "/admin/trains/#{train.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when error occurs during destroying of train" do
      let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

      before do
        allow(Train).to receive(:find).and_return(train)
        allow(train).to receive(:destroy).and_return(false)
        allow(train).to receive(:errors).and_return(errors)

        delete "/admin/trains/#{train.id}", headers: auth_header
      end

      it "returns 422 and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when user is authorized" do
      before do
        delete "/admin/trains/#{train.id}", headers: auth_header
      end

      it "returns 204 and destroys train" do
        expect(response).to have_http_status(:no_content)
        expect { train.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
