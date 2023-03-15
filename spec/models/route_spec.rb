require 'rails_helper'

RSpec.describe Route, type: :model do
  let(:route) { create(:route, :route_with_many_stations) }
  let(:route_with_trains) { create(:route, :route_with_trains) }

  describe 'associations' do
    describe 'stations' do
      it 'has many stations' do
        expect(described_class.reflect_on_association(:stations).macro).to eq(:has_many)
      end

      it 'orders stations according to increasing their order number', long: true do
        route.stations.pluck(:order_number).each_cons(2) { expect(_2 > _1).to eq(true) }
      end
    end

    describe 'station_order_numbers' do
      it 'has many station order numbers' do
        expect(described_class.reflect_on_association(:station_order_numbers).macro).to eq(:has_many)
      end

      it 'destroys with route', long: true do
        route_id = route.id
        stations_ids = route.stations.pluck(:id)
        route.destroy
        expect(StationOrderNumber.where(route_id: route_id,
                                        station_id: stations_ids).count).to eq(0)
      end
    end

    describe 'train' do
      it 'has many trains' do
        expect(described_class.reflect_on_association(:trains).macro).to eq(:has_many)
      end

      it 'nullifies route_id attribute of related trains when destroying' do
        route_with_trains.destroy
        expect(route_with_trains.trains.reload.pluck(:route_id).all?(:nil?)).to be_truthy
      end
    end
  end
end
