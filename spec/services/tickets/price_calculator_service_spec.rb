RSpec.describe Tickets::PriceCalculatorService do
  subject(:service) { described_class.call(ticket: ticket) }

  let(:ticket) do
    create(:ticket, seat: seat, price: price, arrival_point: arrival_point, departure_point: departure_point)
  end

  let(:price) { 1.0 }

  let(:seat) { create(:seat, carriage: carriage, number: seat_number) }
  let(:seat_number) { 1 }
  let(:carriage) { create(:carriage, type: type, train: train) }
  let(:type) { create(:carriage_type, cost_per_hour: 1.0) }

  let(:names_list) { %w[Grodno Mosty Volkovysk Minsk] }

  let(:stations) { create_list(:station, names_list.size, :station_sequence_with_name_list, list: names_list) }
  let(:route) do
    create(:route, :route_with_specific_stations, standard_travel_time: standard_travel_time, stations: stations)
  end

  let(:stoppage_time) { 15 }
  let(:station_travel_time) { 10 }
  let(:standard_travel_time) do
    ((names_list.size - 2) * (stoppage_time + station_travel_time) + station_travel_time).minutes
  end
  let(:start_time) { DateTime.now.utc + 1.day }


  let(:train) do
    create(:train, :train_with_specific_stops,
           route: route,
           stops_at: stations,
           start_time: start_time,
           travel_time: station_travel_time,
           stoppage_time: stoppage_time)
  end

  let(:arrival_point) { train.stops.last }
  let(:departure_point) { train.stops.first }

  include_context "with sequence cleaner"

  describe "#calculate" do
    context "when train goes 2x faster than standard time" do
      before do
        route.standard_travel_time *= 2.0
        route.save
      end

      it "success? is true, price increases by 100% (2 times)" do
        result = service

        expect(result).to be_success
        expect(result.data.price).to eq(price * 2)
      end
    end

    context "when train goes 2x slower than standard time" do
      before do
        route.standard_travel_time /= 2.0
        route.save
      end

      it "success? is true, price decreases by 50% (2 times)" do
        result = service

        expect(result).to be_success
        expect(result.data.price).to eq(price / 2)
      end
    end

    context "when left 3 hours before train departure" do
      let(:start_time) { DateTime.now.utc + 3.hours }

      it "success? is true, price increases by 15% (1.15 times)" do
        result = service

        expect(result).to be_success
        expect(result.data.price).to eq(price * 1.15)
      end
    end

    context "when left more than 6 hours before train departure" do
      it "success? is true, price stays same" do
        result = service

        expect(result).to be_success
        expect(result.data.price).to eq(price)
      end
    end

    context "when user selected upper seat" do
      let(:seat_number) { 2 }

      it "success? is true, price decreases by 25% (4/3 times)" do
        result = service

        expect(result).to be_success
        expect(result.data.price).to eq(price * 0.75)
      end
    end
  end
end
