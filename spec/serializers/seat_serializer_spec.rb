

RSpec.describe SeatSerializer do
  let(:seat) { create(:seat) }
  let(:serializer) { described_class.new(seat) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "attributes" do
    it "has id, number and is taken attributes, type is seat, id is correct" do
      expect(result[:type]).to eq(:seat)
      expect(result[:id]).to eq(seat.id.to_s)

      expect(result[:attributes]).to eq({
                                          id: seat.id,
                                          number: seat.number,
                                          is_taken: seat.is_taken
                                        })
    end
  end
end
