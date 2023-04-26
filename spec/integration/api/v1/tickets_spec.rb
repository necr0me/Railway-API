require "swagger_helper"

RSpec.describe "api/v1/tickets", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:ticket) { create(:ticket, user: user) }

  path "/api/v1/tickets" do
    post "Creates new ticket. By necr0me" do
      tags "Tickets"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          ticket: {
            type: :object,
            properties: {
              user_id: { type: :integer },
              seat_id: { type: :integer },
              departure_station_id: { type: :integer },
              arrival_station_id: { type: :integer },
              price: { type: :number, format: :float }
            },
            required: %i[user_id seat_id departure_station_id arrival_station_id price],
            example: {
              user_id: 1,
              seat_id: 1,
              departure_station_id: 1,
              arrival_station_id: 2,
              price: 10.0
            }
          },
          required: %i[ticket]
        }
      }
      produces "application/json"
      security [Bearer: {}]

      let(:seat) { create(:seat) }
      let(:departure_station) { create(:station) }
      let(:arrival_station) { create(:station, name: "Sydney") }
      let(:price) { 10 }
      let(:params) do
        {
          user_id: user.id,
          seat_id: seat.id,
          departure_station_id: departure_station.id,
          arrival_station_id: arrival_station.id,
          price: price
        }
      end

      response "201", "Ticket successfully created" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "422", "Error occurred during ticket create" do
        let(:price) { nil }

        include_context "with integration test"
      end
    end
  end

  path "/api/v1/tickets/{ticket_id}" do
    let(:ticket_id) { ticket.id }

    get "Gets concrete ticket. By necr0me" do
      tags "Tickets"
      security [Bearer: {}]
      parameter name: :ticket_id, in: :path, type: :integer, required: true,
                description: "Id of ticket that you want to find"
      produces "application/json"

      response "200", "Ticket was found" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        let(:another_user) { create(:user, email: "m@mail.co") }
        let(:Authorization) { "Bearer #{access_token_for(another_user)}" }

        include_context "with integration test"
      end

      response "404", "Ticket not found" do
        let(:ticket_id) { -1 }

        include_context "with integration test"
      end
    end

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
        let(:another_user) { create(:user, email: "m@mail.co") }
        let(:Authorization) { "Bearer #{access_token_for(another_user)}" }

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
