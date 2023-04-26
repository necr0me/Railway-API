RSpec.describe "Admin::Carriages", type: :request do
  let(:user) { create(:user, role: :admin) }

  let(:carriage_type) { create(:carriage_type) }

  let(:carriage) { create(:carriage) }

  describe "#index" do
    context "when user is unauthorized" do
      before do
        get "/admin/carriages"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized" do
      before do
        create_list(:carriage, 6)
        get "/admin/carriages/#{query_param}", headers: auth_header
      end

      context "when query param is presented" do
        let(:query_param) { "?page=2" }

        it "returns ok, list of 1 carriage and number of pages" do
          expect(response).to have_http_status(:ok)

          expect(json_response[:carriages][:data].count).to eq(1)
          expect(json_response[:pages]).to eq((Carriage.count / 5.0).ceil)
        end
      end

      context "when query param is not presented" do
        let(:query_param) { "" }

        it "returns ok, list of 5 carriage and number of pages" do
          expect(response).to have_http_status(:ok)

          expect(json_response[:carriages][:data].count).to eq(5)
          expect(json_response[:pages]).to eq((Carriage.count / 5.0).ceil)
        end
      end
    end
  end

  describe "#show" do
    context "when user is unauthorized" do
      before do
        get "/admin/carriages/#{carriage.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized" do
      before do
        get "/admin/carriages/#{carriage.id}", headers: auth_header
      end

      it "returns 200 and proper carriage" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:carriage][:data][:id].to_i).to eq(carriage.id)
      end
    end
  end

  describe "#create" do
    context "when user is unauthorized" do
      before do
        post "/admin/carriages", params: {
          carriage: attributes_for(:carriage)
        }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and tries to create carriage with invalid data" do
      before do
        post "/admin/carriages",
             params: {
               carriage: {
                 name: "x",
                 carriage_type_id: carriage_type.id
               }
             },
             headers: auth_header
      end

      it "returns 422 and error message that name is too short" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors][:name]).to include(/is too short/)
      end
    end

    context "when user is authorized and tries to create carriage with valid data" do
      before do
        post "/admin/carriages",
             params: {
               carriage: {
                 name: "New_name",
                 carriage_type_id: carriage_type.id
               }
             },
             headers: auth_header
      end

      it "returns 201 and created carriage" do
        expect(response).to have_http_status(:created)
        expect(json_response[:carriage][:data][:id].to_i).to eq(Carriage.last.id)
      end
    end
  end

  describe "#update" do
    context "when user is unauthorized" do
      before do
        patch "/admin/carriages/#{carriage.id}", params: {
          carriage: {
            name: "New_name"
          }
        }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and tries to update carriage with invalid data" do
      before do
        patch "/admin/carriages/#{carriage.id}",
              params: {
                carriage: {
                  name: "x"
                }
              },
              headers: auth_header
      end

      it "returns 422 and contains error message that name is too short" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors][:name]).to include(/is too short/)
      end
    end

    context "when user is authorized and tries to update carriage with valid data" do
      before do
        patch "/admin/carriages/#{carriage.id}",
              params: {
                carriage: {
                  name: "New_name"
                }
              },
              headers: auth_header
      end

      it "returns 200 and updated carriage" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:carriage][:data][:id].to_i).to eq(carriage.id)
        expect(carriage.reload.name).to eq("New_name")
      end
    end
  end

  describe "#destroy" do
    context "when user is unauthorized" do
      before do
        delete "/admin/carriages/#{carriage.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when error occurs during destroy of carriage" do
      let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

      before do
        allow(Carriage).to receive(:find).and_return(carriage)
        allow(carriage).to receive(:destroy).and_return(false)
        allow(carriage).to receive(:errors).and_return(errors)

        delete "/admin/carriages/#{carriage.id}", headers: auth_header
      end

      it "returns 422 and error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Error message")
      end
    end

    context "when user is authorized and tries to destroy carriage" do
      before do
        delete "/admin/carriages/#{carriage.id}", headers: auth_header
      end

      it "returns 204 and deleted carriage from db" do
        expect(response).to have_http_status(:no_content)
        expect { carriage.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
