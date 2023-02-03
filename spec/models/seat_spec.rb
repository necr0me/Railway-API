require 'rails_helper'

RSpec.describe Seat, type: :model do
  let(:seat) { build(:seat) }

  describe 'associations' do
    context 'Carriage' do
      it 'belongs to carriage' do
        expect(described_class.reflect_on_association(:carriage).macro).to eq(:belongs_to)
      end
    end
  end

  describe 'validations' do
    context '#number' do
      it 'is invalid when number is less then 1 or blank' do
        seat.number = nil
        expect(seat).to_not be_valid

        seat.number = 0
        expect(seat).to_not be_valid
      end

      it 'is valid when number greater than or equal to 1' do
        seat.number = 1
        expect(seat).to be_valid

        seat.number = 10
        expect(seat).to be_valid
      end
    end
  end
end
