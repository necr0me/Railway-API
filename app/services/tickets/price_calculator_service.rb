module Tickets
  class PriceCalculatorService < ApplicationService
    def initialize(ticket:)
      @ticket = ticket
      @travel_time = ticket.arrival_time - ticket.departure_time
    end

    def call
      calculate
    end

    private

    attr_reader :ticket, :travel_time

    UPPER_SEAT_COEFFICIENT = 0.75

    MAX_LEFT_TIME = 6.hours
    LEFT_TIME_MAX_COEFFICIENT = 0.3

    def calculate
      ticket.price = coefficient_for_travel_time * price_by_travel_time
      ticket.price *= coefficient_for_left_time if Time.now.utc + MAX_LEFT_TIME > ticket.departure_time
      ticket.price *= UPPER_SEAT_COEFFICIENT if ticket.seat.number.even?

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
  end
end
