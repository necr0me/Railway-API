RSpec.describe TrainStop, type: :model do
  let(:train_stop) { build(:train_stop) }

  describe "associations" do
    describe "Stations" do
      it "belongs to station" do
        expect(described_class.reflect_on_association(:station).macro).to eq(:belongs_to)
      end
    end

    describe "Trains" do
      it "belongs to train" do
        expect(described_class.reflect_on_association(:train).macro).to eq(:belongs_to)
      end
    end
  end

  describe "scopes" do
    let(:time) { DateTime.now }

    before do
      create(:train_stop, arrival_time: time + 5.minutes, departure_time: time + 10.minutes, train: create(:train))
      create(:train_stop, arrival_time: time - 5.minutes, departure_time: time, train: create(:train))
      create(:train_stop, arrival_time: time.yesterday, departure_time: time.yesterday + 5.minutes, train: create(:train))
    end

    describe "#arrives_before" do
      it "returns train stops that arriving before time" do
        expect(described_class.arrives_before(time).pluck(:arrival_time)).to all(be < time)
      end
    end

    describe "#arrives_at_the_day" do
      it "returns train stops that arriving only at selected day" do
        expect(described_class.arrives_at_the_day(time).pluck(:arrival_time))
          .to all(be_between(time.at_beginning_of_day, time.at_end_of_day))
      end
    end

    describe "#arrives_after" do
      it "returns train stops that arriving after selected time" do
        expect(described_class.arrives_after(time).pluck(:arrival_time)).to all(be > time)
      end
    end
  end

  describe "validations" do
    describe "departure time and arrival time" do
      context "when departure time > arrival time" do
        it "is invalid" do
          train_stop.departure_time = DateTime.now
          train_stop.arrival_time = DateTime.now + 20.minutes
          expect(train_stop).not_to be_valid
        end
      end

      context "when departure time < arrival time" do
        it "is valid" do
          train_stop.departure_time = DateTime.now
          train_stop.arrival_time = DateTime.now - 20.minutes
          expect(train_stop).to be_valid
        end
      end
    end

    describe "arrival time and departure time of last stop" do
      let!(:other_stop) { create(:train_stop) }

      context "when arrival time < departure_time of last stop" do
        it "is invalid" do
          train_stop.arrival_time = other_stop.departure_time - 1.minute
          train_stop.departure_time = other_stop.departure_time

          expect(train_stop).not_to be_valid
          expect(train_stop.errors[:arrival_time]).to include("can't be less than departure time of last stop")
        end
      end

      context "when arrival time > departure_time of last stop" do
        it "is valid" do
          train_stop.arrival_time = other_stop.departure_time + 1.minute
          train_stop.departure_time = train_stop.arrival_time

          expect(train_stop).to be_valid
        end
      end
    end

    describe "arrival time and departure time of previous stop" do
      let!(:previous_stop) { create(:train_stop) }
      let!(:train_stop) do
        create(:train_stop,
               arrival_time: previous_stop.departure_time + 1.minute,
               departure_time: previous_stop.departure_time + 1.minute)
      end

      context "when arrival time < departure time of previous stop" do
        it "is invalid" do
          train_stop.arrival_time = previous_stop.departure_time - 1.minute

          expect(train_stop).not_to be_valid
          expect(train_stop.errors[:arrival_time]).to include("can't be less than departure time of previous stop")
        end
      end

      context "when arrival time > departure time of previous stop" do
        it "is valid" do
          train_stop.arrival_time = previous_stop.departure_time + 1.minute

          expect(train_stop).to be_valid
        end
      end
    end

    describe "departure time and arrival time of next stop" do
      let!(:train_stop) { create(:train_stop) }
      let!(:next_stop) do
        create(:train_stop,
               arrival_time: train_stop.departure_time + 1.minute,
               departure_time: train_stop.departure_time + 1.minute)
      end

      context "when departure time < arrival time of next stop" do
        it "is invalid" do
          train_stop.departure_time = next_stop.arrival_time + 1.minute

          expect(train_stop).not_to be_valid
          expect(train_stop.errors[:departure_time]).to include("can't be greater than arrival time of next stop")
        end
      end

      context "when departure time > arrival time of next stop" do
        it "is valid" do
          train_stop.departure_time = next_stop.arrival_time - 1.minute

          expect(train_stop).to be_valid
        end
      end
    end
  end
end
