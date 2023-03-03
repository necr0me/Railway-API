require 'rails_helper'

RSpec.describe Station, type: :model do

  let(:station) { create(:station) }
  let(:invalid_station) { build(:station, name: ' ') }
  let(:station_in_route) { create(:station, :station_with_route) }

  describe 'associations' do
    context 'routes' do
      it 'has many routes' do
        expect(described_class.reflect_on_association(:routes).macro).to eq(:has_many)
      end
    end

    context 'station_order_numbers' do
      it 'has many station order numbers' do
        expect(described_class.reflect_on_association(:station_order_numbers).macro).to eq(:has_many)
      end

      it 'destroys with station' do
        route_id = station_in_route.routes.first.id
        station_id = station_in_route.id
        station_in_route.destroy
        expect { StationOrderNumber.find_by!(route_id: route_id,
                                             station_id: station_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'passing_trains' do
      let(:station) { create(:station, :station_with_passing_trains) }

      it 'has many passing trains' do
        expect(described_class.reflect_on_association(:passing_trains).macro).to eq(:has_many)
      end

      it 'destroys with station' do
        expect { station.destroy }.to change { station.passing_trains.size }.from(3).to(0)
      end
    end

    context 'trains' do
      it 'has many trains' do
        expect(described_class.reflect_on_association(:trains).macro).to eq(:has_many)
      end
    end
  end

  describe 'auto_strip_attributes' do
    context '#name' do
      it 'removes redundant whitespaces at start and at the end' do
        invalid_station.name = "\s\s\sName With Whitespaces\s\s\s"
        invalid_station.save
        expect(invalid_station.name.count(' ')).to eq(2)
      end

      it 'removes tabulations' do
        invalid_station.name = "Name\t\t\tWith\t\t\tTabulations"
        invalid_station.save
        expect(invalid_station.name.count(' ')).to eq(2)
      end
    end
  end

  describe 'validations' do
    context '#name' do
      it 'invalid when blank' do
        expect(invalid_station).to_not be_valid
        expect(invalid_station.errors[:name]).to include("can't be blank")
      end

      it 'invalid when length of name < 2' do
        invalid_station.name = 'x'
        expect(invalid_station).to_not be_valid
        expect(invalid_station.errors[:name]).to include(/too short/)
      end

      it 'invalid when length of name > 50' do
        invalid_station.name = 'x' * 51
        expect(invalid_station).to_not be_valid
        expect(invalid_station.errors[:name]).to include(/too long/)
      end

      it 'invalid when name is not unique' do
        invalid_station.name = station.name
        expect(invalid_station).to_not be_valid
        expect(invalid_station.errors[:name]).to include('has already been taken')
      end

      it 'valid with valid name' do
        expect(station).to be_valid
      end
    end
  end
end
