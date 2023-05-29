RSpec.describe TrainSerializer do
  let(:train) { create(:train) }
  let(:serializer) { described_class.new(train) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "associations" do
    include_context "with sequence cleaner"

    describe "carriages" do
      let(:train) { create(:train, :train_with_carriages) }

      it "includes correct carriages" do
        expect(result[:relationships][:carriages][:data].map { _1[:id].to_i }).to eq(train.carriages.pluck(:id))
      end
    end

    describe "stops" do
      let(:train) { create(:train, :train_with_stops) }

      it "includes correct stops" do
        expect(result[:relationships][:stops][:data].map { _1[:id].to_i }).to eq(train.stops.pluck(:id))
      end
    end

    describe "route" do
      let(:route) { create(:route) }
      let(:train) { create(:train, route: route) }

      it "includes correct route" do
        expect(result[:relationships][:route][:data][:id].to_i).to eq(route.id)
      end
    end
  end

  describe "attributes" do
    it "has attribute destination, type is train, id is correct" do
      expect(result[:type]).to eq(:train)
      expect(result[:id]).to eq(train.id.to_s)
    end
  end

  describe "attribute destination" do
    context "when route or destination is nil" do
      it "returns 'No destination'" do
        expect(result[:attributes][:destination]).to eq("No destination")
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
