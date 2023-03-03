require 'rails_helper'

RSpec.describe PassingTrain, type: :model do
  let(:passing_train) { build(:passing_train) }

  describe 'associations' do
    context 'Stations' do
      it 'belongs to station' do
        expect(described_class.reflect_on_association(:station).macro).to eq(:belongs_to)
      end
    end

    context 'Trains' do
      it 'belongs to train' do
        expect(described_class.reflect_on_association(:train).macro).to eq(:belongs_to)
      end
    end
  end

  describe 'validations' do
    context 'departure time and arrival time' do
      it 'is invalid when departure time > arrival time' do
        passing_train.departure_time = DateTime.now
        passing_train.arrival_time = DateTime.now + 20.minutes
        expect(passing_train).to_not be_valid
      end

      it 'is valid when departure time < arrival time' do
        passing_train.departure_time = DateTime.now
        passing_train.arrival_time = DateTime.now - 20.minutes
        expect(passing_train).to be_valid
      end
    end
  end
end
