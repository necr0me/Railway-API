

RSpec.describe FoundTrainsSerializer do
  let(:names) { %w[Grodno Mosty Lida Minsk] }
  let(:stations) { create_list(:station, names.size, :station_sequence_with_name_list, list: names) }

  let(:starting_station) { stations.second.name }
  let(:ending_station) { stations.third.name }
  let(:service_result) do
    Trains::FinderService.call(
      starting_station: starting_station,
      ending_station: ending_station,
      date: DateTime.now
    ).data
  end

  let(:serializer) { described_class.new(service_result) }
  let(:result) { serializer.serializable_hash[:data] }

  include_context "with sequence cleaner"

  before do
    create(:train, :train_with_specific_stops, stops_at: stations)
    create(:train, :train_with_specific_stops, stops_at: stations[1..2], start_time: DateTime.now + 5.minutes)
  end

  describe "attributes" do
    it "has starting station, ending station and trains attributes" do
      expect(result).to include(*%i[starting_station ending_station trains])

      expect(result[:starting_station]).to eq(starting_station)
      expect(result[:ending_station]).to eq(ending_station)
    end

    it "each element from trains has id, arrives at, departs at and travel time attributes" do
      expect(result[:trains]).to all(include(*%i[id arrives_at departs_at travel_time]))
    end
  end
end
