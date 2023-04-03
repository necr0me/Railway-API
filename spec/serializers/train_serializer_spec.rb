RSpec.describe TrainSerializer do
  let(:train) { create(:train) }
  let(:serializer) { described_class.new(train) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "attributes" do
    it "has attribute destination, type is train, id is correct" do
      expect(result[:type]).to eq(:train)
      expect(result[:id]).to eq(train.id.to_s)
    end
  end

  describe "attribute destination" do
    context "when route or destination is nil" do
      it "returns '-'" do
        expect(result[:attributes][:destination]).to eq("-")
      end
    end

    context "when destination is not nil" do
      include_context "with sequence cleaner"

      let(:route) { create(:route, :route_with_stations) }
      let(:train) { create(:train, route: route) }

      it "returns destination" do
        route.destination = "#{route.stations.first.name} - #{route.stations.last.name}"
        route.save
        route.reload

        expect(result[:attributes][:destination]).to eq(train.destination)
      end
    end
  end
end
