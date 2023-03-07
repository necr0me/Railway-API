require 'rails_helper'

RSpec.describe Trains::TrainsFinderService do
  subject do
    described_class.call(
      starting_station: starting_station_name,
      ending_station: ending_station_name
    )
  end

  let(:names) { %w[Hrodna Mosty Lida Minsk] }
  let(:stations) { create_list(:station, names.size, :station_sequence_with_name_list, list: names) }
  let(:train_hrodna_minsk) { create(:train, :train_with_specific_stops, stops_at: stations) }
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
      before { create(:passing_train) }

      it 'returns all PassingTrain' do
        result = subject.data
        expect(result.size).to eq(PassingTrain.all.size)
        expect(result).to all(be_kind_of(PassingTrain))
      end
    end

    context 'when date, but not the stations are presented' do
      let(:date) { DateTime.now + 3.minutes }
      let(:day_option) { :before }

      before do
        train_hrodna_minsk
        train_mosty_lida
      end

      it 'returns trains Hrodna - Minsk, but not Mosty - Lida' do
        result = subject.data.pluck(:train_id)

        expect(result).to include(train_hrodna_minsk.id)
        expect(result).to_not include(train_mosty_lida.id)
      end
    end

    context 'when date and starting or ending station are presented' do
      let(:starting_station_name) { train_mosty_lida.stops.first.station.name }
      let(:date) { DateTime.now }

      before { train_hrodna_minsk }

      it 'returns trains that passing through selected station' do
        result = subject.data.pluck(:train_id)

        expect(result).to include(train_mosty_lida.id, train_hrodna_minsk.id)
      end
    end

    context 'when date and ending station are presented' do
      let(:ending_station_name) { train_mosty_lida.stops.last.station.name }
      let(:date) { DateTime.now }

      before { train_hrodna_minsk }

      it 'returns trains that passing through selected station' do
        result = subject.data.pluck(:train_id)

        expect(result).to include(train_mosty_lida.id, train_hrodna_minsk.id)
      end
    end

    context 'when date, starting and ending station are presented' do
      let(:starting_station_name) { train_mosty_lida.stops.first.station.name }
      let(:ending_station_name) { train_hrodna_minsk.stops.last.station.name }
      let(:date) { DateTime.now }

      it 'returns Hrodna - Minsk train, but not Mosty - Lida' do
        result = subject.data.pluck(:train_id)

        expect(result).to include(train_hrodna_minsk.id)
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
      let(:starting_station_name) { train_hrodna_minsk.stops.third.station.name }
      let(:ending_station_name) { train_mosty_lida.stops.first.station.name }

      it 'returns nothing' do
        service = subject
        service.send(:set_stations!)
        query = service.send(:trains_between_stations, PassingTrain.joins(:station, :train))

        expect(query.pluck(:train_id)).to be_empty
      end
    end

    context 'when trying to find trains between station, but stations in correct order' do
      let(:starting_station_name) { train_mosty_lida.stops.first.station.name }
      let(:ending_station_name) { train_hrodna_minsk.stops.third.station.name }

      it 'returns Hrodna - Minsk and Mosty - Lida trains' do
        service = subject
        service.send(:set_stations!)
        query = service.send(:trains_between_stations, PassingTrain.joins(:station, :train))

        expect(query.pluck(:train_id)).to include(train_mosty_lida.id, train_hrodna_minsk.id)
      end
    end
  end
end
