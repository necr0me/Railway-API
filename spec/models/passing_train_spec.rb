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

  describe 'scopes' do
    let(:time) { DateTime.now }

    before do
      create(:passing_train, arrival_time: time + 5.minutes, departure_time: time + 10.minutes)
      create(:passing_train, arrival_time: time - 5.minutes, departure_time: time)
      create(:passing_train, arrival_time: time.yesterday, departure_time: time.yesterday + 5.minutes)
    end

    context '#arrives_before' do
      it 'returns passing trains that arriving before time' do
        expect(PassingTrain.arrives_before(time).pluck(:arrival_time)).to all(be < time)
      end
    end

    context '#arrives_at_the_day' do
      it 'returns passing trains that arriving only at selected day' do
        expect(PassingTrain.arrives_at_the_day(time).pluck(:arrival_time))
          .to all(be_between(time.at_beginning_of_day, time.at_end_of_day))
      end
    end

    context '#arrives_after' do
      it 'returns passing trains that arriving after selected time' do
        expect(PassingTrain.arrives_after(time).pluck(:arrival_time)).to all(be > time)
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
