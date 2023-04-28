RSpec.describe Tickets::CreatorService do
  subject(:service) { described_class.call(tickets_params: tickets_params) }

  let(:profile) { create(:profile) }
  let(:other_profile) { create(:profile, passport_code: "KH#{'1' * 7}", phone_number: "1" * 7) }

  let(:seat) { create(:seat) }
  let(:other_seat) { create(:seat) }

  let(:station) { create(:station) }
  let(:price) { 1 }

  let(:tickets_params) do
    { departure_station_id: station.id,
      arrival_station_id: station.id,
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
      ] }
  end

  describe "#call" do
    it "calls create_ticket method" do
      expect_any_instance_of(described_class).to receive(:create_tickets).with(no_args)
      service
    end
  end

  describe "#create_ticket" do
    context "when seat is taken" do
      let(:seat) { create(:seat, is_taken: true) }

      it "does not create tickets, data is nil and contains error that seat is already taken" do
        expect(service.data).to be_nil
        expect(service.error).to eq("Seat ##{seat.number} is taken")

        expect { Ticket.find_by!(seat_id: seat.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(Ticket.where(seat_id: [seat.id, other_seat.id]).size).to eq(0)
      end
    end

    context "when seat is not taken, but error occurs during ticket create" do
      let(:price) { nil }

      it "does not create tickets, data is nil and contains error" do
        expect(service.data).to be_nil
        expect(service.error).not_to be_nil

        expect(Ticket.where(seat_id: [seat.id, other_seat.id]).size).to eq(0)
      end
    end

    context "when seat is not taken and no error occurs during ticket create" do
      it "creates tickets, data and error are nil" do
        expect(service.data).to be_nil
        expect(service.error).to be_nil

        expect(Ticket.where(seat_id: [seat.id, other_seat.id]).size).to eq(2)
      end
    end
  end
end
