RSpec.describe RouteSerializer do
  let(:route) { create(:route, :route_with_stations) }
  let(:serializer) { described_class.new(route) }
  let(:result) { serializer.serializable_hash[:data] }

  include_context "with sequence cleaner"

  describe "associations" do
    it "includes stations, their ids are correct" do
      expect(result[:relationships]).to include(:stations)

      expect(result[:relationships][:stations][:data].map { _1[:id].to_i }).to eq(route.stations.pluck(:id))
    end
  end

  describe "attributes" do
    it "has attribute :destination, type :route, id is correct" do
      expect(result[:type]).to eq(:route)
      expect(result[:id]).to eq(route.id.to_s)

      expect(result[:attributes]).to include(*%i[destination])
    end
  end

  describe "#destination attribute" do
    context "when destination is nil" do
      it "returns '-'" do
        expect(result[:attributes][:destination]).to eq("-")
      end
    end

    context "when destination is not nil" do
      it "returns destination" do
        route.destination = "#{route.stations.first.name} - #{route.stations.last.name}"
        route.save

        expect(result[:attributes][:destination]).to eq(route.reload.destination)
      end
    end
  end
end
