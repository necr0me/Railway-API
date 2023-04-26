require "swagger_helper"

RSpec.describe "admin/tickets", type: :request, swagger_doc: "admin/swagger.yaml" do
  let(:user) { create(:user, role: :admin) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:ticket) { create(:ticket, user: create(:user, email: "m@m.m")) }

  path "/admin/tickets/{ticket_id}" do
    let(:ticket_id) { ticket.id }

    delete "Deletes concrete ticket. By necr0me" do
      tags "Tickets"
      security [Bearer: {}]
      parameter name: :ticket_id, in: :path, type: :integer, required: true,
                description: "Id of ticket that you want to destroy"
      produces "application/json"

      response "200", "Ticket successfully destroyed" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:user) { create(:user, role: :moderator) }

        include_context "with integration test"
      end

      response "404", "Ticket not found" do
        let(:ticket_id) { -1 }

        include_context "with integration test"
      end

      response "422", "Error occurred during ticket destroy" do
        let(:errors) { instance_double(ActiveModel::Errors, full_messages: ["Error message"]) }

        before do
          allow(Ticket).to receive(:find).and_return(ticket)
          allow(ticket).to receive(:destroy).and_return(false)
          allow(ticket).to receive(:errors).and_return(errors)
        end

        include_context "with integration test"
      end
    end
  end
end
