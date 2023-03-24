

RSpec.describe CarriageTypeSerializer do
  let(:carriage_type) { create(:carriage_type) }
  let(:serializer) { described_class.new(carriage_type) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "attributes" do
    it "has attributes name, description and capacity, type is carriage_type, id is correct" do
      expect(result[:type]).to eq(:carriage_type)
      expect(result[:id]).to eq(carriage_type.id.to_s)

      expect(result[:attributes]).to eq({
                                          name: carriage_type.name,
                                          description: carriage_type.description,
                                          capacity: carriage_type.capacity
                                        })
    end
  end
end
