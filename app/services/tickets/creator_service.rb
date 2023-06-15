module Tickets
  class CreatorService < ApplicationService
    def initialize(tickets_params:)
      @tickets_params = tickets_params
    end

    def call
      create_tickets
    end

    private

    attr_reader :tickets_params

    def create_tickets
      ActiveRecord::Base.transaction do
        tickets_params[:passengers].each do |passenger|
          seat = Seat.find(passenger[:seat_id])
          seat_taken?(seat)
          train_departs_in_5_minutes?

          service = Tickets::PriceCalculatorService.call(ticket: Ticket.new(
            **passenger,
            departure_stop_id: tickets_params[:departure_stop_id],
            arrival_stop_id: tickets_params[:arrival_stop_id]
          ))

          ticket_saved?(service)

          seat.update!(is_taken: true)
        end
      end
    end

    def seat_taken?(seat)
      return unless seat.is_taken

      fail!(error: "Место ##{seat.number} занято")
      raise ActiveRecord::Rollback
    end

    def train_departs_in_5_minutes?
      return if TrainStop.find(tickets_params[:arrival_stop_id]).departure_time + 5.minutes < Time.now.utc

      fail!(error: "Невозможно купить билет за 5 минут до отправления")
      raise ActiveRecord::Rollback
    end

    def ticket_saved?(service)
      return if service.success? && service.data&.save

      fail!(error: service.error || service.data&.errors)
      raise ActiveRecord::Rollback
    end
  end
end
