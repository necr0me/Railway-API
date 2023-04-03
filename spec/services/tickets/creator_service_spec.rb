RSpec.describe Tickets::CreatorService do
  subject(:service) { described_class.call(ticket_params: ticket_params) }

  let(:user) { create(:user) }
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

  describe "#call" do
    it "calls create_ticket method" do
      expect_any_instance_of(described_class).to receive(:create_ticket).with(no_args)
      service
    end
  end

  describe "#create_ticket" do
    context "when seat is taken" do
      let(:seat) { create(:seat, is_taken: true) }

      it "does not create ticket, data is nil and contains error that seat is already taken" do
        expect(service.data).to be_nil
        expect(service.error).to eq("Seat is already taken")
        expect { Ticket.find_by!(seat_id: seat.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when seat is not taken, but error occurs during ticket create" do
      let(:price) { nil }

      it "does not create ticket, data is nil and contains error" do
        expect(service.data).to be_nil
        expect(service.error).not_to be_nil
        expect { Ticket.find_by!(seat_id: seat.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when seat is not taken and no error occurs during ticket create" do
      it "creates ticket, data is created ticket and error is nil" do
        expect(service.data).not_to be_nil
        expect(service.error).to be_nil
        expect(service.data.id).to eq(Ticket.last.id)
      end
    end
  end
end
