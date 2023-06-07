module Tickets
  class PriceCalculatorService < ApplicationService
    UPPER_SEAT_COEFFICIENT = 0.75

    def initialize(ticket:)
      @ticket = ticket
      @travel_time = ticket.arrival_time - ticket.departure_time
    end

    def call
      calculate
    end

    private

    attr_reader :ticket, :travel_time

    MAX_LEFT_TIME = 6.hours
    LEFT_TIME_MAX_COEFFICIENT = 0.15

    def calculate
      ticket.price = coefficient_for_travel_time * price_by_travel_time
      ticket.price *= coefficient_for_left_time if out_of_left_time?
      ticket.price *= coefficient_for_distance
      ticket.price *= UPPER_SEAT_COEFFICIENT if even_seat?

      success!(data: ticket)
    end

    def price_by_travel_time
      (travel_time / 1.hour.to_i) * ticket.seat.carriage.type.cost_per_hour
    end

    def coefficient_for_travel_time
      ticket.departure_point.train.route.standard_travel_time.to_i / travel_time
    end

    def coefficient_for_left_time
      1 + [(ticket.departure_time - Time.now.utc) / MAX_LEFT_TIME * LEFT_TIME_MAX_COEFFICIENT,
           LEFT_TIME_MAX_COEFFICIENT].min&.round(2)
    end

    def coefficient_for_distance
      order_numbers = ticket.departure_point.train.route.station_order_numbers
      departure_station_id = ticket.departure_point.station_id
      arrival_station_id = ticket.arrival_point.station_id
      arrival_index, departure_index = order_numbers.where(station_id: [arrival_station_id, departure_station_id])
                                                    .pluck(:order_number)
      (arrival_index - departure_index).abs / (order_numbers.count - 1).to_f
    end

    def out_of_left_time?
      Time.now.utc + MAX_LEFT_TIME > ticket.departure_time
    end

    def even_seat?
      ticket.seat.number.even?
    end
  end
end
