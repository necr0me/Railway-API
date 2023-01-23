require 'rails_helper'

RSpec.describe Routes::StationAdderService do
  let(:route) { create(:route) }
  let(:station) { create(:station) }

  describe '#call' do
    subject { described_class.call(route_id: route.id, station_id: station.id) }

    it 'calls add_station! method' do
      expect_any_instance_of(described_class).to receive(:add_station!).with(no_args)
      subject
    end
  end

  describe '#add_station!' do
    context 'when method is worked' do
      it 'returns OpenStruct object regardless raising errors or not' do
        expect(described_class.call(route_id: route.id,
                                    station_id: station.id)).to be_kind_of(OpenStruct)
        expect(described_class.call(route_id: 0,
                                    station_id: station.id)).to be_kind_of(OpenStruct)
      end
    end

    context 'when any error occurs' do
      subject { described_class.call(route_id: 0, station_id: station.id) }

      it 'success? value is false' do
        expect(subject.success?).to eq(false)
      end

      it 'data value is nil' do
        expect(subject.data).to be_nil
      end

      it 'contains error' do
        expect(subject.errors).to_not be_nil
      end
    end

    context 'when no any errors occurs' do
      subject { described_class.call(route_id: route.id, station_id: station.id) }

      it 'success? value is true' do
        expect(subject.success?).to be(true)
      end

      it 'data value is added station' do
        expect(subject.data.id).to eq(station.id)
      end

      it 'errors value is nil' do
        expect(subject.errors).to be_nil
      end

      it 'adds station to route' do
        subject
        expect(route.reload.stations).to include(station)
      end

      it 'sets correct order number' do
        subject
        expect(route.station_order_numbers.last.order_number).to eq(route.stations.count)
      end
    end
  end
end