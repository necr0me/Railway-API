require 'rails_helper'

RSpec.describe Routes::StationRemoverService do
  let(:route) { create(:route, :with_stations) }
  let(:first_station) { route.stations.first }

  describe '#call' do
    it 'calls remove_station! method' do
      expect_any_instance_of(described_class).to receive(:remove_station!).with(no_args)
      described_class.call(route_id: route.id, station_id: first_station.id)
    end
  end

  describe '#remove_station!' do
    context 'when method is worked' do
      it 'returns OpenStruct object regardless of raising errors or not' do
        expect(described_class.call(route_id: route.id, station_id: 0)).to be_kind_of(OpenStruct)
        expect(described_class.call(route_id: route.id, station_id: first_station.id)).to be_kind_of(OpenStruct)
      end
    end

    context 'when error occurs' do
      subject { described_class.call(route_id: route.id, station_id: 0) }

      it 'success? value is false' do
        expect(subject.success?).to eq(false)
      end

      it 'errors value is not nil' do
        expect(subject.errors).to_not be_nil
      end
    end

    context 'when any error doesn\'t occur' do
      subject { described_class.call(route_id: route.id, station_id: first_station.id) }

      it 'success? value is true' do
        expect(subject.success?).to eq(true)
      end

      it 'errors value is nil' do
        expect(subject.errors).to be_nil
      end

      it 'decrements order numbers of stations after removed station' do
        subject
        expect(route.reload.stations.pluck(:order_number)).to eq((1..route.stations.count).to_a)
      end

      it 'removes station from route' do
        subject
        expect(route.reload.stations).to_not include(first_station)
      end
    end
  end
end
