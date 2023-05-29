RSpec.describe TrainStopSerializer do
  let(:train_stop) { create(:train_stop) }
  let(:serializer) { described_class.new(train_stop) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "associations" do
    it "includes train and station in result, their ids are correct" do
      expect(result[:relationships]).to include(*%i[station train])

      expect(result[:relationships][:station][:data][:id]).to eq(train_stop.station_id.to_s)
      expect(result[:relationships][:train][:data][:id]).to eq(train_stop.train_id.to_s)
    end
  end

  describe "attributes" do
    it "has attributes arrival time, departure time and way number, type is train_stop, id is correct" do
      expect(result[:type]).to eq(:train_stop)
      expect(result[:id]).to eq(train_stop.id.to_s)

      expect(result[:attributes]).to eq({
                                          name: train_stop.station.name,
                                          arrival_time: train_stop.arrival_time,
                                          departure_time: train_stop.departure_time,
                                          train_destination: train_stop.train.destination,
                                          way_number: train_stop.way_number
                                        })
    end
  end
end
