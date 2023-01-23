require 'rails_helper'

RSpec.describe Carriage, type: :model do
  let(:carriage) { build(:carriage) }
  let(:carriage_with_seats) { create(:carriage, :with_seats)}

  describe 'associations' do
    context 'Seat' do
      it 'has many seats' do
        expect(described_class.reflect_on_association(:seats).macro).to eq(:has_many)
      end

      it 'destroys seats with itself' do
        carriage_with_seats.destroy
        expect(Seat.where(carriage_id: carriage_with_seats.id).count).to eq(0)
      end
    end

    context 'CarriageType' do
      it 'belongs to type (CarriageType)' do
        expect(described_class.reflect_on_association(:type).macro).to eq(:belongs_to)
      end
    end

    context 'Train' do
      it 'belongs to train' do
        expect(described_class.reflect_on_association(:train).macro).to eq(:belongs_to)
      end

      it 'train is optional' do
        expect { carriage.save }.to_not raise_error
      end
    end
  end

  describe 'auto_strip_attributes' do
    context '#name' do
      it 'removes redundant whitespaces' do
        carriage.name = "\s\s\sName\s\s\sWith\s\s\sWhitespaces\s\s\s"
        carriage.save
        expect(carriage.name.count(' ')).to eq(2)
      end

      it 'removes redundant tabulations' do
        carriage.name = "\t\t\tName\t\t\tWith\t\t\tTabulations\t\t\t"
        carriage.save
        expect(carriage.name.count(' ')).to eq(2)
      end
    end
  end

  describe 'validations' do
    context '#name' do
      it 'is invalid when name is blank' do
        carriage.name = ''
        expect(carriage).to_not be_valid
        expect(carriage.errors[:name]).to include(/can't be blank/)
      end

      it 'is invalid when name is too short (3-)' do
        carriage.name = 'x'
        expect(carriage).to_not be_valid
        expect(carriage.errors[:name]).to include(/too short/)
      end

      it 'is invalid when name is too long (32+)' do
        carriage.name = 'x' * 33
        expect(carriage).to_not be_valid
        expect(carriage.errors[:name]).to include(/too long/)
      end
    end
  end

  describe '#capacity' do
    it 'returns train capacity' do
      expect(carriage.capacity).to eq(carriage.type.capacity)
    end
  end
end
