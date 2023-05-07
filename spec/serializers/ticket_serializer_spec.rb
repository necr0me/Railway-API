RSpec.describe TicketSerializer do
  let(:ticket) { create(:ticket) }
  let(:serializer) { described_class.new(ticket) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "associations" do
    it "includes arrival and departure stations, seat, their ids are correct" do
      expect(result[:relationships]).to include(*%i[seat])

      expect(result[:relationships][:seat][:data][:id]).to eq(ticket.seat_id.to_s)
    end
  end

  describe "attributes" do
    it "has price attribute, type is ticket, id is correct" do
      expect(result[:type]).to eq(:ticket)
      expect(result[:id]).to eq(ticket.id.to_s)

      expect(result[:attributes]).to eq({ price: ticket.price,
                                          arrival_time: ticket.arrival_time,
                                          departure_time: ticket.departure_time })
    end
  end
end
