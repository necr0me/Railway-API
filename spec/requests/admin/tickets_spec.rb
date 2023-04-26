RSpec.describe "Admin::Tickets", type: :request do
  let(:user) { create(:user, role: :admin) }
  let(:ticket) { create(:ticket, user: user) }

  describe "#destroy" do
    context "when user is unauthorized" do
      before do
        delete "/admin/tickets/#{ticket.id}"
      end

      it "returns 401, does not destroy ticket" do
        expect(response).to have_http_status(:unauthorized)
        expect { ticket.reload }.not_to raise_error
      end
    end

    context "when user is authorized, but error occurs during ticket destroy" do
      before do
        allow_any_instance_of(Ticket).to receive(:destroy).and_return(false)
        allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return(["Error message"])
        delete "/admin/tickets/#{ticket.id}",
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
        delete "/admin/tickets/#{ticket.id}",
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
