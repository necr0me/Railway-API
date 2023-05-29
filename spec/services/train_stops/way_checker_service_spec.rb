RSpec.describe TrainStops::WayCheckerService do
  subject(:service) { described_class.call(station: station, train_stop: train_stop) }

  let(:station) { create(:station) }
  let(:train_stop) { build(:train_stop, station: station) }

  let(:now) { Time.now.utc }
  let(:stop_one) { create(:train_stop, arrival_time: now, departure_time: now + 2.minutes) }
  let(:stop_two) { create(:train_stop, arrival_time: now + 3.minutes, departure_time: now + 5.minutes) }

  describe "#call" do
    context "when no any stops on this way" do
      it "success? is true" do
        result = service

        expect(result).to be_success
      end
    end

    context "when no any intersections with other trains stops" do
      before do
        train_stop.arrival_time = stop_one.departure_time + 6.minutes
        train_stop.departure_time = stop_two.departure_time + 1.minute
      end

      it "success? is true" do
        result = service

        expect(result).to be_success
      end
    end

    context "when train stop intersects with other train stops" do
      before do
        train_stop.arrival_time = stop_one.departure_time
        train_stop.departure_time = stop_two.arrival_time
      end

      it "success? is false, contains error message that way is taken" do
        result = service

        expect(result).not_to be_success
        expect(result.error[:way_number]).to include(/\d+ is taken/)
      end
    end
  end

  describe "#before_arrival?" do
    context "when train stops before arrival of other train" do
      before do
        train_stop.arrival_time = stop_one.arrival_time - 5.minutes
        train_stop.departure_time = stop_one.arrival_time - 3.minutes
      end

      it "returns true" do
        expect(service.send(:before_arrival?, stop_one)).to be_truthy
      end
    end

    context "when train stops after arrival of other train" do
      before do
        train_stop.arrival_time = stop_one.departure_time
        train_stop.departure_time = stop_one.departure_time + 2.minutes
      end

      it "returns false" do
        expect(service.send(:before_arrival?, stop_one)).to be_falsey
      end
    end
  end

  describe "#after_departure?" do
    context "when train stops after departure of other train" do
      before do
        train_stop.arrival_time = stop_one.departure_time + 1.minute
        train_stop.departure_time = stop_one.departure_time + 2.minutes
      end

      it "returns true" do
        expect(service.send(:after_departure?, stop_one)).to be_truthy
      end
    end

    context "when train stops before departure of other train" do
      before do
        train_stop.arrival_time = stop_one.arrival_time - 5.minutes
        train_stop.departure_time = stop_one.arrival_time - 3.minutes
      end

      it "returns false" do
        expect(service.send(:after_departure?, stop_one)).to be_falsey
      end
    end
  end
end
