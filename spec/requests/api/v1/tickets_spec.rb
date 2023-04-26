RSpec.describe "Api::V1::Tickets", type: :request do
  let(:user) { create(:user) }
  let(:ticket) { create(:ticket, user: user) }

  describe "#show" do
    context "when user is unauthorized" do
      before do
        get "/api/v1/tickets/#{ticket.id}"
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authorized" do
      before do
        get "/api/v1/tickets/#{ticket.id}",
            headers: auth_header
      end

      it "returns 200 and found ticket" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:ticket][:id]).to eq(ticket.id)
      end
    end
  end

  describe "#create" do
    let(:seat) { create(:seat) }
    let(:station) { create(:station) }
    let(:price) { 1 }

    let(:ticket_params) do
      {
        user_id: user.id,
        seat_id: seat.id,
        departure_station_id: station.id,
        arrival_station_id: station.id,
        price: price
      }
    end

    context "when user is unauthorized" do
      before do
        post "/api/v1/tickets",
             params: { ticket: ticket_params }
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
             params: { ticket: ticket_params }
      end

      it "returns 422 and errors" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
      end
    end

    context "when user is authorized and no error occurs during ticket create" do
      before do
        post "/api/v1/tickets",
             headers: auth_header,
             params: { ticket: ticket_params }
      end

      it "returns 201 and created ticket" do
        expect(response).to have_http_status(:created)
        expect(json_response[:ticket][:id]).to eq(Ticket.last.id)
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
