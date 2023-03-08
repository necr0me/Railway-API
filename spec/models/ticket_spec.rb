require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'associations' do
    context 'user' do
      it 'belongs to user' do
        expect(described_class.reflect_on_association(:user).macro).to eq(:belongs_to)
      end
    end

    context 'seat' do
      it 'belongs to seat' do
        expect(described_class.reflect_on_association(:seat).macro).to eq(:belongs_to)
      end
    end

    context 'departure_station' do
      it 'belongs to departure station' do
        expect(described_class.reflect_on_association(:departure_station).macro).to eq(:belongs_to)
      end
    end

    context 'destination_station' do
      it 'belongs to destination station' do
        expect(described_class.reflect_on_association(:arrival_station).macro).to eq(:belongs_to)
      end
    end
  end

  describe 'callbacks' do
    describe '#before_destroy' do
      let(:ticket) { create(:ticket) }

      it 'frees seat when destroying' do
        seat = ticket.seat
        ticket.destroy
        expect(seat.reload.is_taken).to be_falsey
      end
    end
  end

  describe 'validations' do
    describe 'price' do
      context 'when price is missing' do
        let(:ticket) { build(:ticket, price: nil) }

        it 'is invalid' do
          expect(ticket).to_not be_valid
        end
      end

      context 'when price < 0' do
        let(:ticket) { build(:ticket, price: -1) }

        it 'is invalid' do
          expect(ticket).to_not be_valid
        end
      end

      context 'when price >= 0' do
        let(:ticket) { build(:ticket, price: 1.5) }

        it 'is valid' do
          expect(ticket).to be_valid
        end
      end
    end
  end
end
