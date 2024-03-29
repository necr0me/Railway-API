RSpec.describe StationOrderNumber, type: :model do
  let(:route) { create(:route, :route_with_stations) }
  let(:station) { create(:station) }
  let(:station_order_number) do
    build(:station_order_number,
          route_id: route.id,
          station_id: station.id)
  end

  describe "associations" do
    describe "routes" do
      it "belongs to routes" do
        expect(described_class.reflect_on_association(:route).macro).to eq(:belongs_to)
      end
    end

    describe "stations" do
      it "belongs to stations" do
        expect(described_class.reflect_on_association(:station).macro).to eq(:belongs_to)
      end
    end
  end

  describe "scopes", long: true do
    include_context "with sequence cleaner"

    before { create(:route, :route_with_stations) }

    it "by default sorts according to increasing order number" do
      described_class.all.pluck(:order_number).each_cons(2) { expect(_1 <= _2).to be_truthy }
    end
  end

  describe "validations" do
    include_context "with sequence cleaner"

    describe "#order_number" do
      before { station_order_number.save }

      context "when order number is less than 1" do
        it "is invalid" do
          station_order_number.order_number = 0
          expect(station_order_number).not_to be_valid
        end
      end

      context "when order number >= 1" do
        it "is valid" do
          station_order_number.order_number = 1
          expect(station_order_number).to be_valid

          station_order_number.order_number = 10
          expect(station_order_number).to be_valid
        end
      end
    end
  end

  describe "order" do
    include_context "with sequence cleaner"

    it "order station order numbers according to increasing order number" do
      route.station_order_numbers.pluck(:order_number).each_cons(2) { expect(_2 > _1).to eq(true) }
    end
  end

  describe "#set_order_number!" do
    include_context "with sequence cleaner"

    it "sets created station correct order number" do
      expect { station_order_number.save }.to change(station_order_number, :order_number)
        .from(nil).to(route.stations.count + 1)
    end
  end
end
