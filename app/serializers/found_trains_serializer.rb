class FoundTrainsSerializer
  def initialize(result)
    @result = result
  end

  attr_reader :result

  def serializable_hash
    {
      data: {
        starting_station: result[:starting_station]&.name,
        ending_station: result[:ending_station]&.name,
        trains: result[:passing_trains].map { |pair| parse_pair(pair) }
      }
    }
  end

  private

  def parse_pair(pair)
    {
      id: pair.first.train_id,
      departs_at: pair.first.departure_time,
      arrives_at: pair.last.arrival_time,
      travel_time: pair.last.arrival_time - pair.first.departure_time
    }
  end
end
