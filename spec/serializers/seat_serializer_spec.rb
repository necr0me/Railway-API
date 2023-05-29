RSpec.describe SeatSerializer do
  let(:seat) { create(:seat) }
  let(:serializer) { described_class.new(seat) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "attributes" do
    describe "attribute number" do
      context "when number is < 10" do
        let(:seat) { create(:seat, number: 1) }

        it "adds leading zero" do
          expect(result[:attributes][:number][0]).to eq("0")
        end
      end

      context "when number is >= 10" do
        let(:seat) { create(:seat, number: 11) }

        it "changes nothing" do
          expect(result[:attributes][:number][0]).to eq(seat.number.to_s[0])
        end
      end
    end

    describe "all attributes" do
      it "has id, number and is taken attributes, type is seat, id is correct" do
        expect(result[:type]).to eq(:seat)
        expect(result[:id]).to eq(seat.id.to_s)

        expect(result[:attributes]).to eq({
                                            id: seat.id,
                                            number: "%02d" % seat.number.to_s,
                                            is_taken: seat.is_taken
                                          })
      end
    end
  end
end
