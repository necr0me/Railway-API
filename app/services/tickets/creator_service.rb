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
          if seat.is_taken
            fail!(error: "Seat ##{seat.number} is taken")
            raise ActiveRecord::Rollback
          end

          Ticket.create!(**passenger,
                         departure_stop_id: tickets_params[:departure_stop_id],
                         arrival_stop_id: tickets_params[:arrival_stop_id])

          seat.update!(is_taken: true)
        end
      end
    end
  end
end
