RSpec.describe "Api::V1::Tickets", type: :request do
  let(:user) { create(:user, :user_with_profile) }

  let(:profile) { user.profiles.first }
  let(:ticket) { create(:ticket, profile: profile) }

  describe "#index" do
    context "when user is unauthorized" do
      before do
        get "/api/v1/tickets"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized" do
      before do
        create(:ticket, profile: profile)
        get "/api/v1/tickets", headers: auth_header
      end

      it "returns 200 and list of user's tickets" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:tickets].map { _1[:profile_id] }.uniq).to eq(user.profiles.pluck(:id))
      end
    end
  end

  describe "#create" do
    let(:seat) { create(:seat) }
    let(:other_seat) { create(:seat) }

    let(:other_profile) { create(:profile, passport_code: "KH#{'2' * 7}", phone_number: "3" * 7) }

    let(:train_stop) { create(:train_stop) }
    let(:price) { 1 }

    let(:tickets_params) do
      {
        departure_stop_id: train_stop.id,
        arrival_stop_id: train_stop.id,
        passengers: [
          {
            profile_id: profile.id,
            seat_id: seat.id,
            price: price
          },
          {
            profile_id: other_profile.id,
            seat_id: other_seat.id,
            price: price
          }
        ]
      }
    end

    context "when user is unauthorized" do
      before do
        post "/api/v1/tickets",
             params: { tickets: tickets_params }
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized, but error occurred during ticket create" do
      let(:price) { nil }

      before do
        post "/api/v1/tickets",
             headers: auth_header,
             params: { tickets: tickets_params }
      end

      it "returns 422 and errors, does not creates tickets" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
        expect(user.tickets.size).to eq(0)
      end
    end

    context "when user is authorized and no error occurs during ticket create" do
      before do
        post "/api/v1/tickets",
             headers: auth_header,
             params: { tickets: tickets_params }
      end

      it "returns 201 and creates tickets" do
        expect(response).to have_http_status(:created)
        expect(Ticket.pluck(:id)).to eq(user.tickets.pluck(:id))
      end
    end
  end

  describe "#destroy" do
    context "when user is unauthorized" do
      before do
        delete "/api/v1/tickets/#{ticket.id}"
      end

      it "returns 401, does not destroy ticket" do
        expect(response).to have_http_status(:unauthorized)
        expect { ticket.reload }.not_to raise_error
      end
    end

    context "when user is authorized, but error occurs during ticket destroy" do
      before do
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(ticket).to receive(:destroy).and_return(false)
        delete "/api/v1/tickets/#{ticket.id}",
               headers: auth_header
      end

      it "returns 422 and errors, does not destroy ticket" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
        expect { ticket.reload }.not_to raise_error
      end
    end

    context "when user is authorized and no error occurs during ticket destroy" do
      before do
        delete "/api/v1/tickets/#{ticket.id}",
               headers: auth_header
      end

      it "returns 200, message that ticket successfully destroyed and destroys ticket" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq("Ticket successfully destroyed")
        expect { ticket.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
