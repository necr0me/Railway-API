RSpec.describe CarriageSerializer do
  let(:carriage) { create(:carriage) }
  let(:serializer) { described_class.new(carriage) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "associations" do
    describe "seats" do
      context "when params[:include_seats] is false" do
        let(:serializer) { described_class.new(carriage, { params: { include_seats: false } }) }

        it "does not returns seats" do
          expect(result[:relationships]).not_to include(:seats)
        end
      end

      context "when params is blank" do
        it "returns seats" do
          expect(result[:relationships]).to include(:seats)
        end
      end

      context "when params[:include_seats] is true" do
        let(:serializer) { described_class.new(carriage, { params: { include_seats: true } }) }

        it "returns seats" do
          expect(result[:relationships]).to include(:seats)
        end
      end
    end
  end

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

    describe "attribute order_number" do
      context "when order_number < 10" do
        let(:carriage) { create(:carriage, order_number: 1) }

        it "adds leading zero" do
          expect(result[:attributes][:order_number][0]).to eq("0")
        end
      end

      context "when order_number >= 10" do
        let(:carriage) { create(:carriage, order_number: 11) }

        it "changes nothing" do
          expect(result[:attributes][:order_number][0]).to eq(carriage.order_number.to_s[0])
        end
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
                                            free_seats: carriage.amount_of_free_seats,
                                            order_number: format("%02d", carriage.order_number.to_s),
                                            carriage_type_id: carriage.type.id
                                          })
      end
    end
  end
end
