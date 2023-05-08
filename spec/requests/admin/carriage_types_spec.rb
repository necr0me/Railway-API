RSpec.describe "Admin::CarriageTypes", type: :request do
  let(:user) { create(:user, role: :admin) }

  let(:carriage_type) { create(:carriage_type) }
  let(:carriage_type_with_carriage) { create(:carriage_type, :type_with_carriage) }

  describe "#index" do
    context "when user is unauthorized" do
      before do
        get "/admin/carriage_types"
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized" do
      before do
        create_list(:carriage_type, 6)
        get "/admin/carriage_types/#{query_param}", headers: auth_header
      end

      context "when query param 'page' is presented" do
        let(:query_param) { "?page=2" }

        it "returns ok, list of 1 carriage type and number of pages" do
          expect(response).to have_http_status(:ok)

          expect(json_response[:carriage_types][:data].count).to eq(1)
          expect(json_response[:pages]).to eq((CarriageType.count / 5.0).ceil)
        end
      end

      context "when query param 'page' is not presented" do
        let(:query_param) { "" }

        it "returns ok, list of all carriage types, number of pages equals 1" do
          expect(response).to have_http_status(:ok)

          expect(json_response[:carriage_types][:data].count).to eq(CarriageType.count)
          expect(json_response[:pages]).to eq(1)
        end
      end
    end
  end

  describe "#create" do
    context "when user is unauthorized" do
      before do
        post "/admin/carriage_types", params: attributes_for(:carriage_type)
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and tries to create type with invalid data" do
      before do
        post "/admin/carriage_types",
             params: {
               carriage_type: {
                 name: "x",
                 description: "x" * 141,
                 capacity: -1
               }
             },
             headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and contains error messages" do
        expect(response).to have_http_status(:unprocessable_entity)

        expect(json_response[:errors][:name]).to include(/is too short/)
        expect(json_response[:errors][:description]).to include(/is too long/)
        expect(json_response[:errors][:capacity]).to include(/must be greater than or equal to 0/)
      end
    end

    context "when user is authorized and tries to create type with valid data" do
      before do
        post "/admin/carriage_types",
             params: {
               carriage_type: attributes_for(:carriage_type)
             },
             headers: auth_header
      end

      it "returns 201 and created carriage type" do
        expect(response).to have_http_status(:created)
        expect(json_response[:carriage_type][:data][:id].to_i).to eq(CarriageType.last.id)
      end
    end
  end

  describe "#update" do
    context "when user is unauthorized" do
      before do
        patch "/admin/carriage_types/#{carriage_type.id}", params: attributes_for(:carriage_type)
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and tries to update type with invalid data" do
      before do
        patch "/admin/carriage_types/#{carriage_type.id}",
              params: {
                carriage_type: {
                  name: carriage_type.name,
                  description: carriage_type.description,
                  capacity: -1
                }
              },
              headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and contains error message" do
        expect(response).to have_http_status(:unprocessable_entity)

        expect(json_response[:errors][:capacity]).to include(/must be greater than or equal to 0/)
      end
    end

    context "when user is authorized and tries to update type with valid data" do
      before do
        patch "/admin/carriage_types/#{carriage_type.id}",
              params: {
                carriage_type: {
                  name: carriage_type.name,
                  description: carriage_type.description,
                  capacity: 2
                }
              },
              headers: auth_header
      end

      it "returns OK and updated carriage type" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:carriage_type][:data][:id].to_i).to eq(carriage_type.id)
        expect(json_response[:carriage_type][:data][:attributes][:capacity].to_i).to eq(2)
      end
    end
  end

  describe "#destroy" do
    context "when user is unauthorized" do
      before do
        delete "/admin/carriage_types/#{carriage_type.id}"
      end

      it "returns UNAUTHORIZED" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized and tries to destroy type with carriages" do
      before do
        delete "/admin/carriage_types/#{carriage_type_with_carriage.id}", headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and contains error message that cant delete type that has any carriages" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Can't destroy carriage type that has any carriages")
      end
    end

    context "when user is authorize and tries to destroy type without any carriages" do
      before do
        delete "/admin/carriage_types/#{carriage_type.id}", headers: auth_header
      end

      it "returns 204 and destroys type from db" do
        expect(response).to have_http_status(:no_content)
        expect { carriage_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
