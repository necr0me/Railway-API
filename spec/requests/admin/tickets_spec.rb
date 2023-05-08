RSpec.describe "Admin::Tickets", type: :request do
  let(:user) { create(:user, :user_with_profile, role: :admin) }
  let(:profile) { user.profiles.first }
  let(:ticket) { create(:ticket, profile: profile) }

  describe "#destroy" do
    context "when user is unauthorized" do
      before do
        delete "/admin/tickets/#{ticket.id}"
      end

      it "returns UNAUTHORIZED, does not destroy ticket" do
        expect(response).to have_http_status(:unauthorized)
        expect { ticket.reload }.not_to raise_error
      end
    end

    context "when user is authorized, but error occurs during ticket destroy" do
      before do
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(ticket).to receive(:destroy).and_return(false)

        delete "/admin/tickets/#{ticket.id}",
               headers: auth_header
      end

      it "returns UNPROCESSABLE_ENTITY and errors, does not destroy ticket" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).not_to be_nil
        expect { ticket.reload }.not_to raise_error
      end
    end

    context "when user is authorized and no error occurs during ticket destroy" do
      before do
        delete "/admin/tickets/#{ticket.id}",
               headers: auth_header
      end

      it "returns OK, message that ticket successfully destroyed and destroys ticket" do
        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq("Ticket successfully destroyed")
        expect { ticket.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
