require 'rails_helper'

RSpec.describe StationOrderNumber, type: :model do
  let(:route) { create(:route, :route_with_stations) }
  let(:station) { create(:station) }
  let(:station_order_number) { build(:station_order_number,
                                     route_id: route.id,
                                     station_id: station.id)}

  describe 'associations' do
    context 'routes' do
      it 'belongs to routes' do
        expect(described_class.reflect_on_association(:route).macro).to eq(:belongs_to)
      end
    end

    context 'stations' do
      it 'belongs to stations' do
        expect(described_class.reflect_on_association(:station).macro).to eq(:belongs_to)
      end
    end
  end

  describe 'scopes', long: true do
    before { create(:route, :route_with_stations) }

    it 'by default sorts according to increasing order number' do
      StationOrderNumber.all.pluck(:order_number).each_cons(2) { expect(_1 <= _2).to be_truthy }
    end
  end

  describe 'validations' do
    context '#order_number' do
      before { station_order_number.save }

      it 'is invalid when order number is less than 1' do
        station_order_number.order_number = 0
        expect(station_order_number).to_not be_valid
      end

      it 'is valid when order number is greater than or equal to 1' do
        station_order_number.order_number = 1
        expect(station_order_number).to be_valid

        station_order_number.order_number = 10
        expect(station_order_number).to be_valid
      end
    end
  end

  describe 'order' do
    it 'order station order numbers according to increasing order number' do
      route.station_order_numbers.pluck(:order_number).each_cons(2) { expect(_2 > _1).to eq(true) }
    end
  end

  describe '#set_order_number!' do
    it 'sets created station correct order number' do
      expect { station_order_number.save }.to change(station_order_number, :order_number)
                                                .from(nil).to(route.stations.count + 1)
    end
  end
end
