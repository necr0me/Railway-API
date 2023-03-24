

RSpec.describe StationSerializer do
  let(:station) { create(:station) }
  let(:serializer) { described_class.new(station) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "attributes" do
    it "has name attribute, type is station, id is correct" do
      expect(result[:type]).to eq(:station)
      expect(result[:id]).to eq(station.id.to_s)

      expect(result[:attributes]).to eq({ name: station.name })
    end
  end
end
