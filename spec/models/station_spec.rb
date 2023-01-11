require 'rails_helper'

RSpec.describe Station, type: :model do

  let(:station) { create(:station) }
  let(:invalid_station) { build(:station, name: ' ') }

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
