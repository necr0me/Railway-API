RSpec.describe FoundTrainsSerializer do
  let(:names) { %w[Grodno Mosty Lida Minsk] }
  let(:stations) { create_list(:station, names.size, :station_sequence_with_name_list, list: names) }

  let(:departure_station) { stations.second }
  let(:arrival_station) { stations.third }
  let(:service_result) do
    Trains::FinderService.call(
      departure_station: departure_station&.name,
      arrival_station: arrival_station&.name,
      date: DateTime.now
    ).data
  end

  let(:serializer) { described_class.new(service_result) }
  let(:result) { serializer.serializable_hash[:data] }

  include_context "with sequence cleaner"

  before do
    create(:train, :train_with_specific_stops, stops_at: stations)
    create(:train, :train_with_specific_stops, stops_at: stations[1..2])
  end

  describe "attributes" do
    it "has starting station, ending station and trains attributes" do
      expect(result).to include(*%i[departure_station arrival_station trains])

      expect(result[:departure_station][:id]).to eq(departure_station.id.to_s)
      expect(result[:arrival_station][:id]).to eq(arrival_station.id.to_s)
    end

    it "each element from trains has id, arrives at, departs at and travel time attributes" do
      expect(result[:trains]).to all(include(*%i[id attributes]))
    end

    describe "ticket price" do
      context "when starting or ending stations are nil" do
        let(:departure_station) { nil }

        it "does not includes types_summary attribute" do
          expect(result[:trains].map { _1[:attributes] }).to all(exclude(:types_summary))
        end
      end

      context "when starting and ending stations are not nil" do
        it "includes types_summary attribute" do
          expect(result[:trains].map { _1[:attributes] }).to all(include(:types_summary))
        end
      end
    end
  end
end
