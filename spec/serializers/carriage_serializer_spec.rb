RSpec.describe CarriageSerializer do
  let(:carriage) { create(:carriage) }
  let(:serializer) { described_class.new(carriage) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "attributes" do
    describe "attribute available" do
      context "when carriage has not train" do
        it "available is false" do
          expect(result[:attributes][:available]).to eq(true)
        end
      end

      context "when carriage has train" do
        let(:carriage) { create(:carriage, train_id: create(:train).id) }

        it "available is true" do
          expect(result[:attributes][:available]).to eq(false)
        end
      end
    end

    describe "attribute type" do
      it "returns name of type of carriage type" do
        expect(result[:attributes][:type]).to eq(carriage.type.name)
      end
    end

    describe "all attributes" do
      it "has attributes name, type and capacity, type is carriage, id is correct" do
        expect(result[:type]).to eq(:carriage)
        expect(result[:id]).to eq(carriage.id.to_s)

        expect(result[:attributes]).to eq({
                                            name: carriage.name,
                                            type: carriage.type.name,
                                            capacity: carriage.capacity,
                                            available: carriage.train_id.nil?,
                                            carriage_type_id: carriage.type.id
                                          })
      end
    end
  end
end
