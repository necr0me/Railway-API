RSpec.describe CarriageTypeSerializer do
  let(:carriage_type) { create(:carriage_type) }
  let(:serializer) { described_class.new(carriage_type) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "associations" do
    describe "carriages" do
      let(:carriage_type) { create(:carriage_type, :type_with_carriage) }

      it "includes correct carriages" do
        expect(result[:relationships][:carriages][:data].map { _1[:id].to_i }).to eq(carriage_type.carriages.pluck(:id))
      end
    end
  end

  describe "attributes" do
    it "has attributes name, description and capacity, type is carriage_type, id is correct" do
      expect(result[:type]).to eq(:carriage_type)
      expect(result[:id]).to eq(carriage_type.id.to_s)

      expect(result[:attributes]).to eq({
                                          name: carriage_type.name,
                                          description: carriage_type.description,
                                          capacity: carriage_type.capacity,
                                          cost_per_hour: carriage_type.cost_per_hour
                                        })
    end
  end
end
