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
        trains: result[:trains].map { |pair| parse_pair(pair) }
      }
    }
  end

  private

  def parse_pair(pair)
    {
      id: pair.first.train_id,
      attributes: {
        destination: pair.first.train.destination,
        departs_to: pair.first.station.name,
        departs_at: pair.first.departure_time,
        arrives_to: pair.last.station.name,
        arrives_at: pair.last.arrival_time,
        travel_time: pair.last.arrival_time - pair.first.departure_time
      }.tap { |h| h[:types_summary] = types_summary(pair) if result[:arrival_station] && result[:departure_station] }
    }
  end

  # TODO: remember about type difference in seats amount (TYPE and their SUBTYPES)
  def types_summary(pair)
    carriages = pair.first.train.carriages.preload(:type)
    carriages.map(&:type).uniq
             .map { |type| type_price_pair(type, pair).merge(free: calculate_free_seats(pair.first.train_id, type)) }
  end

  def type_price_pair(type, pair)
    basic_seat_price = calculate_price(type, pair)
    {
      type: type.name,
      type_id: type.id,
      prices: {
        bottom: basic_seat_price,
        upper: basic_seat_price * Tickets::PriceCalculatorService::UPPER_SEAT_COEFFICIENTS[type.name.to_sym]
      }
    }
  end

  def calculate_free_seats(train_id, type)
    type.carriages.where(train_id: train_id).inject(0) { |sum, carriage| sum + carriage.amount_of_free_seats }
  end

  def calculate_price(type, pair)
    Tickets::PriceCalculatorService.call(ticket: Ticket.new(
      departure_point: pair.first,
      arrival_point: pair.last,
      seat: type.carriages.where.not(train_id: nil).first.seats.first
    )).data&.price
  end
end
