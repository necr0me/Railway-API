RSpec.describe PassingTrain, type: :model do
  let(:passing_train) { build(:passing_train) }

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
      create(:passing_train, arrival_time: time + 5.minutes, departure_time: time + 10.minutes)
      create(:passing_train, arrival_time: time - 5.minutes, departure_time: time)
      create(:passing_train, arrival_time: time.yesterday, departure_time: time.yesterday + 5.minutes)
    end

    describe "#arrives_before" do
      it "returns passing trains that arriving before time" do
        expect(described_class.arrives_before(time).pluck(:arrival_time)).to all(be < time)
      end
    end

    describe "#arrives_at_the_day" do
      it "returns passing trains that arriving only at selected day" do
        expect(described_class.arrives_at_the_day(time).pluck(:arrival_time))
          .to all(be_between(time.at_beginning_of_day, time.at_end_of_day))
      end
    end

    describe "#arrives_after" do
      it "returns passing trains that arriving after selected time" do
        expect(described_class.arrives_after(time).pluck(:arrival_time)).to all(be > time)
      end
    end
  end

  describe "validations" do
    describe "departure time and arrival time" do
      context "when departure time > arrival time" do
        it "is invalid" do
          passing_train.departure_time = DateTime.now
          passing_train.arrival_time = DateTime.now + 20.minutes
          expect(passing_train).not_to be_valid
        end
      end

      context "when departure time < arrival time" do
        it "is valid" do
          passing_train.departure_time = DateTime.now
          passing_train.arrival_time = DateTime.now - 20.minutes
          expect(passing_train).to be_valid
        end
      end
    end
  end
end
