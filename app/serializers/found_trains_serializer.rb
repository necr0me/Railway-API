class FoundTrainsSerializer
  def initialize(result)
    @result = result
  end

  attr_reader :result

  def serializable_hash
    {
      data: {
        departure_station: {
          id: result[:departure_station]&.id.to_s,
          attributes: {
            name: result[:departure_station]&.name
          }
        },
        arrival_station: {
          id: result[:arrival_station]&.id.to_s,
          attributes: {
            name: result[:arrival_station]&.name
          }
        },
        trains: result[:passing_trains].map { |pair| parse_pair(pair) }
      }
    }
  end

  private

  def parse_pair(pair)
    {
      id: pair.first.train_id,
      attributes: {
        destination: pair.first.train.destination,
        departs_at: pair.first.departure_time,
        arrives_at: pair.last.arrival_time,
        travel_time: pair.last.arrival_time - pair.first.departure_time
      }
    }
  end
end
