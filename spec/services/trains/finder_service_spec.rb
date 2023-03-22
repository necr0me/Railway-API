require 'rails_helper'

RSpec.describe Trains::FinderService do
  subject do
    described_class.call(
      starting_station: starting_station_name,
      ending_station: ending_station_name
    )
  end

  # TODO: try to refactor some of tests

  let(:names) { %w[Grodno Mosty Lida Minsk] }
  let(:stations) { create_list(:station, names.size, :station_sequence_with_name_list, list: names) }
  let(:train_grodno_minsk) { create(:train, :train_with_specific_stops, stops_at: stations) }
  let(:train_mosty_lida) do
    create(:train, :train_with_specific_stops, stops_at: stations[1..2], start_time: DateTime.now + 5.minutes)
  end


  describe '#call' do
    let(:starting_station_name) { nil }
    let(:ending_station_name) { nil }

    it 'calls set_stations! method' do
      allow_any_instance_of(described_class).to receive(:set_stations!).with(no_args)
      subject
    end

    it 'calls find_trains method' do
      allow_any_instance_of(described_class).to receive(:find_trains).with(no_args)
      subject
    end
  end

  describe '#set_stations!' do
    let(:starting_station_name) { create(:station, name: 'Hrodna').name }
    let(:ending_station_name) { create(:station, name: 'Minsk').name }

    it 'finds starting station by name and sets result to @starting_station' do
      starting_station = subject.instance_variable_get('@starting_station')

      expect(starting_station).to be_kind_of(Station)
      expect(starting_station.name).to eq(starting_station_name)
    end

    it 'finds ending station by name and sets result to @ending_station' do
      ending_station = subject.instance_variable_get('@ending_station')

      expect(ending_station).to be_kind_of(Station)
      expect(ending_station.name).to eq(ending_station_name)
    end
  end

  describe '#find_trains' do
    subject do
      described_class.call(
        starting_station: starting_station_name,
        ending_station: ending_station_name,
        date: date,
        day_option: day_option
      )
    end

    let(:starting_station_name) { nil }
    let(:ending_station_name) { nil }
    let(:date) { nil }
    let(:day_option) { :at_the_day }

    include_context 'with sequence cleaner'

    context 'when date and stations are not presented' do
      before do
        train_grodno_minsk
        train_mosty_lida
      end

      it 'returns starting and ending stations of all created trains' do
        result = subject.data[:passing_trains].flatten.pluck(:train_id)

        expect(result).to include(train_grodno_minsk.id, train_mosty_lida.id)
      end
    end

    context 'when date, but not the stations are presented' do
      let(:date) { DateTime.now + 3.minutes }
      let(:day_option) { :before }

      before do
        train_grodno_minsk
        train_mosty_lida
      end

      it 'returns train Hrodna - Minsk, but not of train Mosty - Lida' do
        result = subject.data[:passing_trains].flatten.pluck(:train_id)

        expect(result).to include(train_grodno_minsk.id)
        expect(result).to_not include(train_mosty_lida.id)
      end
    end

    context 'when date and starting station are presented' do
      let(:starting_station_name) { train_mosty_lida.stops.first.station.name }
      let(:date) { DateTime.now }

      before { train_grodno_minsk }

      it 'returns trains that passing through selected station' do
        result = subject.data[:passing_trains].flatten.pluck(:train_id)

        expect(result).to include(train_grodno_minsk.id, train_mosty_lida.id)
      end
    end

    context 'when date and ending station are presented' do
      let(:ending_station_name) { train_mosty_lida.stops.last.station.name }
      let(:date) { DateTime.now }

      before { train_grodno_minsk }

      it 'returns trains that passing through selected station' do
        result = subject.data[:passing_trains].flatten.pluck(:train_id)

        expect(result).to include(train_grodno_minsk.id, train_mosty_lida.id)
      end
    end

    context 'when date, starting and ending station are presented' do
      let(:starting_station_name) { train_mosty_lida.stops.first.station.name }
      let(:ending_station_name) { train_grodno_minsk.stops.last.station.name }
      let(:date) { DateTime.now }

      it 'returns Hrodna - Minsk train, but not Mosty - Lida' do
        result = subject.data[:passing_trains].flatten.pluck(:train_id)

        expect(result).to include(train_grodno_minsk.id)
        expect(result).to_not include(train_mosty_lida.id)
      end
    end
  end

  describe '#trains_between_stations' do
    subject do
      described_class.new(
        starting_station: starting_station_name,
        ending_station: ending_station_name
      )
    end

    include_context 'with sequence cleaner'

    context 'when trying to find trains between stations, but stations in reverse order' do
      let(:starting_station_name) { train_grodno_minsk.stops.third.station.name }
      let(:ending_station_name) { train_mosty_lida.stops.first.station.name }

      it 'returns nothing' do
        service = subject
        service.send(:set_stations!)
        query = service.send(:trains_between_stations, PassingTrain.joins(:station, :train))
        result = query.pluck(:train_id)

        expect(result).to be_empty
      end
    end

    context 'when trying to find trains between station, but stations in correct order' do
      let(:starting_station_name) { train_mosty_lida.stops.first.station.name }
      let(:ending_station_name) { train_grodno_minsk.stops.third.station.name }

      it 'returns Hrodna - Minsk and Mosty - Lida trains' do
        service = subject
        service.send(:set_stations!)
        query = service.send(:trains_between_stations, PassingTrain.joins(:station, :train))
        result = query.pluck(:train_id)

        expect(result).to include(train_mosty_lida.id, train_grodno_minsk.id)
      end
    end
  end

  describe '#collect_train_ids' do
    let(:starting_station) { train_grodno_minsk.stops.last.station }
    let(:ending_station) { train_mosty_lida.stops.first.station }

    let(:attributes) do
      {
        starting_station: starting_station.name,
        ending_station: ending_station.name
      }
    end

    include_context 'with sequence cleaner'

    it 'collects ids of trains, that arrival time on next < departure time from previous station' do
      service = described_class.new(**attributes)
      service.send(:set_stations!)
      ending_station_trains = ending_station.passing_trains
      passing_trains = PassingTrain.where(station_id: starting_station.id).where(
        train_id: ending_station_trains.pluck(:train_id)
      )
      result = service.send(:collect_train_ids, passing_trains, ending_station_trains)

      expect(result).to include(train_grodno_minsk.id)
    end
  end

  describe '#finalize_result' do
    let(:starting_station_name) { nil }
    let(:ending_station_name) { nil }

    it 'returns hash that contains keys like :starting_station, :ending_station and :passing_trains' do
      service = subject
      result = service.send(:finalize_result, PassingTrain.all)

      expect(result).to be_a(Hash)
      expect(result.keys).to include(*%i[starting_station ending_station passing_trains])
    end
  end

  describe '#pair_func' do
    let(:starting_station_name) { train_mosty_lida.stops.first.station.name }
    let(:ending_station_name) { train_grodno_minsk.stops.third.station.name }
    let(:stop) { train_mosty_lida.stops.first }

    let(:service) { described_class.new(starting_station: starting_station_name, ending_station: ending_station_name) }

    include_context 'with sequence cleaner'

    context 'when starting and ending stations are presented' do
      it 'returns Proc, that returns array of 2 elements: starting station stop and ending station stop' do
        service.send(:set_stations!)
        pair_func = service.send(:pair_func)
        ending_station = service.send(:ending_station)

        expect(pair_func).to be_a(Proc)
        expect(pair_func.call(stop)).to eq([stop, ending_station.passing_trains.find_by(train_id: stop.train_id)])
      end
    end

    context 'when ONLY ending station presented' do
      let(:starting_station_name) { nil }
      let(:stop) { train_mosty_lida.stops.last }

      it 'returns Proc, that returns array of 2 elements: train starting station stop and ending station stop' do
        service.send(:set_stations!)
        pair_func = service.send(:pair_func)

        expect(pair_func).to be_a(Proc)
        expect(pair_func.call(stop)).to eq([stop.train.stops.first, stop])
      end
    end

    context 'when starting station or no any stations presented' do
      let(:starting_station_name) { nil }
      let(:ending_station_name) { nil }

      it 'returns Proc, that returns array of 2 elements: train starting station stop and train ending station stop' do
        service.send(:set_stations!)
        pair_func = service.send(:pair_func)

        expect(pair_func).to be_a(Proc)
        expect(pair_func.call(stop)).to eq([stop, stop.train.stops.last])
      end
    end
  end
end
