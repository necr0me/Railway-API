RSpec.describe Trains::FinderService do
  subject(:service) do
    described_class.call(
      departure_station: departure_station_name,
      arrival_station: arrival_station_name
    )
  end

  # TODO: try to refactor some of tests

  let(:names) { %w[Grodno Mosty Lida Minsk] }
  let(:stations) { create_list(:station, names.size, :station_sequence_with_name_list, list: names) }
  let(:train_grodno_minsk) { create(:train, :train_with_specific_stops, stops_at: stations) }
  let(:train_mosty_lida) do
    create(:train, :train_with_specific_stops, stops_at: stations[1..2])
  end

  describe "#set_stations!" do
    let(:departure_station_name) { create(:station, name: "Hrodna").name }
    let(:arrival_station_name) { create(:station, name: "Minsk").name }

    it "finds starting station by name and sets result to @departure_station" do
      departure_station = service.instance_variable_get("@departure_station")

      expect(departure_station).to be_kind_of(Station)
      expect(departure_station.name).to eq(departure_station_name)
    end

    it "finds ending station by name and sets result to @arrival_station" do
      arrival_station = service.instance_variable_get("@arrival_station")

      expect(arrival_station).to be_kind_of(Station)
      expect(arrival_station.name).to eq(arrival_station_name)
    end
  end

  describe "#find_trains" do
    subject(:service) do
      described_class.call(
        departure_station: departure_station_name,
        arrival_station: arrival_station_name,
        date: date,
        day_option: day_option
      )
    end

    let(:departure_station_name) { nil }
    let(:arrival_station_name) { nil }
    let(:date) { nil }
    let(:day_option) { :at_the_day }

    include_context "with sequence cleaner"

    context "when date and stations are not presented" do
      before do
        train_grodno_minsk
        train_mosty_lida
      end

      it "returns starting and ending stations of all created trains" do
        result = service.data[:passing_trains].flatten.pluck(:train_id)

        expect(result).to include(train_grodno_minsk.id, train_mosty_lida.id)
      end
    end

    context "when date, but not the stations are presented" do
      let(:date) { DateTime.now + 3.minutes }

      before do
        train_grodno_minsk
        train_mosty_lida
      end

      it "returns train Hrodna - Minsk and train Mosty - Lida" do
        result = service.data[:passing_trains].flatten.pluck(:train_id)

        expect(result).to include(train_grodno_minsk.id)
        expect(result).to include(train_mosty_lida.id)
      end
    end

    context "when date and starting station are presented" do
      let(:departure_station_name) { train_mosty_lida.stops.first.station.name }
      let(:date) { DateTime.now }

      before { train_grodno_minsk }

      it "returns trains that passing through selected station" do
        result = service.data[:passing_trains].flatten.pluck(:train_id)

        expect(result).to include(train_grodno_minsk.id, train_mosty_lida.id)
      end
    end

    context "when date and ending station are presented" do
      let(:arrival_station_name) { train_mosty_lida.stops.last.station.name }
      let(:date) { DateTime.now }

      before { train_grodno_minsk }

      it "returns trains that passing through selected station" do
        result = service.data[:passing_trains].flatten.pluck(:train_id)

        expect(result).to include(train_grodno_minsk.id, train_mosty_lida.id)
      end
    end

    context "when date, starting and ending station are presented" do
      let(:departure_station_name) { train_mosty_lida.stops.first.station.name }
      let(:arrival_station_name) { train_grodno_minsk.stops.last.station.name }
      let(:date) { DateTime.now }

      it "returns Hrodna - Minsk train, but not Mosty - Lida" do
        result = service.data[:passing_trains].flatten.pluck(:train_id)

        expect(result).to include(train_grodno_minsk.id)
        expect(result).not_to include(train_mosty_lida.id)
      end
    end
  end

  describe "#trains_between_stations" do
    subject(:service) do
      described_class.new(
        departure_station: departure_station_name,
        arrival_station: arrival_station_name
      )
    end

    include_context "with sequence cleaner"

    context "when trying to find trains between stations, but stations in reverse order" do
      let(:departure_station_name) { train_grodno_minsk.stops.third.station.name }
      let(:arrival_station_name) { train_mosty_lida.stops.first.station.name }

      it "returns nothing" do
        service.send(:set_stations!)
        query = service.send(:trains_between_stations, TrainStop.joins(:station, :train))
        result = query.pluck(:train_id)

        expect(result).to be_empty
      end
    end

    context "when trying to find trains between station, but stations in correct order" do
      let(:departure_station_name) { train_mosty_lida.stops.first.station.name }
      let(:arrival_station_name) { train_grodno_minsk.stops.third.station.name }

      it "returns Hrodna - Minsk and Mosty - Lida trains" do
        service.send(:set_stations!)
        query = service.send(:trains_between_stations, TrainStop.joins(:station, :train))
        result = query.pluck(:train_id)

        expect(result).to include(train_mosty_lida.id, train_grodno_minsk.id)
      end
    end
  end

  describe "#collect_train_ids" do
    subject(:service) { described_class.new(**attributes) }

    let(:departure_station) { train_grodno_minsk.stops.last.station }
    let(:arrival_station) { train_mosty_lida.stops.first.station }

    let(:attributes) do
      {
        departure_station: departure_station.name,
        arrival_station: arrival_station.name
      }
    end

    include_context "with sequence cleaner"

    it "collects ids of trains, that arrival time on next < departure time from previous station" do
      service.send(:set_stations!)
      arrival_station_trains = arrival_station.train_stops
      passing_trains = TrainStop.where(station_id: departure_station.id).where(
        train_id: arrival_station_trains.pluck(:train_id)
      )
      result = service.send(:collect_train_ids, passing_trains, arrival_station_trains)

      expect(result).to include(train_grodno_minsk.id)
    end
  end

  describe "#finalize_result" do
    let(:departure_station_name) { nil }
    let(:arrival_station_name) { nil }

    it "returns hash that contains keys like :departure_station, :arrival_station and :passing_trains" do
      result = service.send(:finalize_result, TrainStop.all)

      expect(result).to be_a(Hash)
      expect(result.keys).to include(*%i[departure_station arrival_station passing_trains])
    end
  end

  describe "#pair_func" do
    subject(:service) do
      described_class.new(
        departure_station: departure_station_name,
        arrival_station: arrival_station_name
      )
    end

    let(:departure_station_name) { train_mosty_lida.stops.first.station.name }
    let(:arrival_station_name) { train_grodno_minsk.stops.third.station.name }
    let(:stop) { train_mosty_lida.stops.first }

    include_context "with sequence cleaner"

    context "when starting and ending stations are presented" do
      it "returns Proc, that returns array of 2 elements: starting station stop and ending station stop" do
        service.send(:set_stations!)
        pair_func = service.send(:pair_func)
        arrival_station = service.send(:arrival_station)

        expect(pair_func).to be_a(Proc)
        expect(pair_func.call(stop)).to eq([stop, arrival_station.train_stops.find_by(train_id: stop.train_id)])
      end
    end

    context "when ONLY ending station presented" do
      let(:departure_station_name) { nil }
      let(:stop) { train_mosty_lida.stops.last }

      it "returns Proc, that returns array of 2 elements: train starting station stop and ending station stop" do
        service.send(:set_stations!)
        pair_func = service.send(:pair_func)

        expect(pair_func).to be_a(Proc)
        expect(pair_func.call(stop)).to eq([stop.train.stops.first, stop])
      end
    end

    context "when starting station or no any stations presented" do
      let(:departure_station_name) { nil }
      let(:arrival_station_name) { nil }

      it "returns Proc, that returns array of 2 elements: train starting station stop and train ending station stop" do
        service.send(:set_stations!)
        pair_func = service.send(:pair_func)

        expect(pair_func).to be_a(Proc)
        expect(pair_func.call(stop)).to eq([stop, stop.train.stops.last])
      end
    end
  end
end
