require 'rails_helper'

RSpec.describe Routes::StationRemoverService do
  let(:route) { create(:route, :route_with_stations) }
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
      it 'success? is false, contains errors' do
        result = described_class.call(route_id: route.id, station_id: 0)

        expect(result.success?).to eq(false)

        expect(result.errors).to_not be_nil
      end
    end

    context 'when any error doesn\'t occur' do
      it 'success? is true, contains no errors and removes station from route' do
        result = described_class.call(route_id: route.id, station_id: first_station.id)

        expect(result.success?).to eq(true)

        expect(result.errors).to be_nil

        expect(route.reload.stations.pluck(:order_number)).to eq((1..route.stations.count).to_a)

        expect(route.reload.stations).to_not include(first_station)
      end
    end
  end
end
