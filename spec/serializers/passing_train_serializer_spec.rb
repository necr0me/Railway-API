RSpec.describe PassingTrainSerializer do
  let(:passing_train) { create(:passing_train) }
  let(:serializer) { described_class.new(passing_train) }
  let(:result) { serializer.serializable_hash[:data] }

  describe "associations" do
    it "includes train and station in result, their ids are correct" do
      expect(result[:relationships]).to include(*%i[station train])

      expect(result[:relationships][:station][:data][:id]).to eq(passing_train.station_id.to_s)
      expect(result[:relationships][:train][:data][:id]).to eq(passing_train.train_id.to_s)
    end
  end

  describe "attributes" do
    it "has attributes arrival time, departure time and way number, type is carriage_type, id is correct" do
      expect(result[:type]).to eq(:passing_train)
      expect(result[:id]).to eq(passing_train.id.to_s)

      expect(result[:attributes]).to eq({
                                          name: passing_train.station.name,
                                          arrival_time: passing_train.arrival_time,
                                          departure_time: passing_train.departure_time,
                                          way_number: passing_train.way_number
                                        })
    end
  end
end
