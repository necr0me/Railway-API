

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
    it "has type :route, id is correct" do
      expect(result[:type]).to eq(:route)
      expect(result[:id]).to eq(route.id.to_s)
    end
  end
end
