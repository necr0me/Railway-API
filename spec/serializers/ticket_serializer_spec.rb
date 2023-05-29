RSpec.describe TicketSerializer do
  let(:ticket) { create(:ticket, seat: seat) }

  let(:seat) { create(:seat, carriage: carriage) }
  let(:carriage) { train.carriages.first }
  let(:train) { create(:train, :train_with_carriages) }

  let(:serializer) { described_class.new(ticket) }
  let(:result) { serializer.serializable_hash[:data] }

  include_context "with sequence cleaner"

  describe "associations" do
    it "includes seat and profile, their ids are correct" do
      expect(result[:relationships]).to include(*%i[seat profile])

      expect(result[:relationships][:seat][:data][:id]).to eq(ticket.seat_id.to_s)
      expect(result[:relationships][:profile][:data][:id]).to eq(ticket.profile_id.to_s)
    end
  end

  describe "attributes" do
    it "has price attribute, type is ticket, id is correct" do
      expect(result[:type]).to eq(:ticket)
      expect(result[:id]).to eq(ticket.id.to_s)

      expect(result[:attributes]).to eq({ price: ticket.price,
                                          arrival_time: ticket.arrival_time,
                                          departure_time: ticket.departure_time,
                                          train_id: ticket.seat.carriage.train_id,
                                          departure_point: ticket.departure_point.station.name,
                                          arrival_point: ticket.arrival_point.station.name,
                                          destination: ticket.seat.carriage.train.destination })
    end
  end
end
