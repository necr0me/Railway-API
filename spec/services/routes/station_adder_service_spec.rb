RSpec.describe Routes::StationAdderService do
  let(:route) { create(:route) }
  let(:station) { create(:station) }

  describe "#call" do
    it "calls add_station! method" do
      expect_any_instance_of(described_class).to receive(:add_station!).with(no_args)
      described_class.call(route_id: route.id, station_id: station.id)
    end
  end

  describe "#add_station!" do
    context "when any error occurs" do
      it "data is nil and contains error" do
        result = described_class.call(route_id: 0, station_id: station.id)

        expect(result.data).to be_nil
        expect(result.error).not_to be_nil
      end
    end

    context "when no any errors occurs" do
      it " returns added station, does not contain error and adds station to route" do
        result = described_class.call(route_id: route.id, station_id: station.id)

        expect(result.data.id).to eq(station.id)
        expect(result.error).to be_nil

        expect(route.reload.stations).to include(station)
        expect(route.station_order_numbers.last.order_number).to eq(route.stations.count)
      end
    end
  end
end
