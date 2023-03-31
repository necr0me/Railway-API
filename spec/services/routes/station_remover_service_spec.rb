RSpec.describe Routes::StationRemoverService do
  let(:route) { create(:route, :route_with_stations) }
  let(:first_station) { route.stations.first }

  include_context "with sequence cleaner"

  describe "#call" do
    it "calls remove_station! method" do
      expect_any_instance_of(described_class).to receive(:remove_station).with(no_args)
      described_class.call(route_id: route.id, station_id: first_station.id)
    end
  end

  describe "#remove_station!" do
    context "when error occurs" do
      it "returns error" do
        result = described_class.call(route_id: route.id, station_id: 0)

        expect(result.error).not_to be_nil
      end
    end

    context "when any error doesn't occur" do
      it "does not contains errors, removes and returns station from route and updates route destination" do
        result = described_class.call(route_id: route.id, station_id: first_station.id)

        expect(result.error).to be_nil

        expect(result.data).to eq(first_station)

        expect(route.reload.stations.pluck(:order_number)).to eq((1..route.stations.count).to_a)
        expect(route.reload.stations).not_to include(first_station)
        expect(route.destination).to eq("#{route.stations.first.name} - #{route.stations.last.name}")
      end
    end
  end

  describe "#decrement_order_numbers_after" do
    it "decrements order numbers of stations that going after some station in route" do
      after_station = first_station.station_order_numbers.first
      service = described_class.new(route_id: route.id, station_id: first_station.id)
      old_order_numbers = route.station_order_numbers.group_by(&:id).except(after_station.id)
      service.send(:decrement_order_numbers_after, after_station)
      new_order_numbers = route.reload.station_order_numbers.group_by(&:id).except(after_station.id)

      old_order_numbers.each do |k, v|
        expect(v.first.order_number - new_order_numbers[k].first.order_number).to eq(1)
      end
    end
  end

  describe "#update_destination!" do
    before do
      service = described_class.new(route_id: route.id, station_id: nil)
      service.send(:update_destination!, route)
    end

    context "when route stations list is empty" do
      let(:route) { create(:route) }

      it "sets route destination to nil" do
        expect(route.reload.destination).to eq(nil)
      end
    end

    context "when route stations list is not empty" do
      it "sets route destination to format like 'first_station_name - last_station_name'" do
        expect(route.reload.destination).to eq("#{route.stations.first.name} - #{route.stations.last.name}")
      end
    end
  end
end
