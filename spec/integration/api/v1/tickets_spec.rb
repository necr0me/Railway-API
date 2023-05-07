require "swagger_helper"

RSpec.describe "api/v1/tickets", type: :request do
  let(:user) { create(:user, :user_with_profile) }
  let(:Authorization) { "Bearer #{access_token}" }

  let(:profile) { user.profiles.first }
  let(:ticket) { create(:ticket, profile: profile) }

  path "/api/v1/tickets" do
    get "Retrieves user's tickets. By necr0me" do
      tags "Tickets"
      produces "application/json"
      security [Bearer: {}]

      before do
        create_list(:ticket, 2, profile: profile)
      end

      response "200", "Tickets found" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        before { allow(User).to receive(:find).and_return(nil) }

        include_context "with integration test"
      end
    end

    post "Creates new tickets. By necr0me" do
      tags "Tickets"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          tickets: {
            type: :object,
            properties: {
              departure_station_id: { type: :integer },
              arrival_station_id: { type: :integer },
              passengers: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    profile_id: { type: :integer },
                    seat_id: { type: :integer },
                    price: { type: :number, format: :float }
                  },
                  required: %i[profile_id seat_id price]
                }
              }
            },
            required: %i[departure_station_id arrival_station_id passengers],
            example: {
              departure_station_id: 1,
              arrival_station_id: 2,
              passengers: [
                {
                  profile_id: 1,
                  seat_id: 1,
                  price: 10.0
                },
                {
                  profile_id: 2,
                  seat_id: 2,
                  price: 10.0
                }
              ]
            }
          }
        },
        required: %i[tickets]
      }
      produces "application/json"
      security [Bearer: {}]

      let(:departure_stop) { create(:train_stop) }
      let(:arrival_stop) { create(:train_stop, station: create(:station, name: "Sydney")) }

      let(:other_profile) { create(:profile, passport_code: "KH#{'1' * 7}", phone_number: "4" * 7) }

      let(:seat) { create(:seat) }
      let(:other_seat) { create(:seat) }

      let(:price) { 10 }
      let(:params) do
        {
          tickets:
          {
            departure_stop_id: departure_stop.id,
            arrival_stop_id: arrival_stop.id,
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
        }
      end

      response "201", "Tickets successfully created" do
        include_context "with integration test"
      end

      response "401", "You are unauthorized" do
        let(:Authorization) { "invalid" }

        include_context "with integration test"
      end

      response "403", "You are forbidden to perform this action" do
        before { allow(User).to receive(:find).and_return(nil) }

        include_context "with integration test"
      end

      response "422", "Error occurred during tickets create" do
        let(:price) { nil }

        include_context "with integration test"
      end
    end
  end

  path "/api/v1/tickets/{ticket_id}" do
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
