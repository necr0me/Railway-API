module Tickets
  class CreatorService < ApplicationService
    def initialize(ticket_params:)
      @ticket_params = ticket_params
    end

    def call
      create_ticket
    end

    private

    attr_reader :ticket_params

    def create_ticket
      seat = Seat.find(ticket_params[:seat_id])
      return fail!(error: 'Seat is already taken') if seat.is_taken

      ticket = Ticket.create(ticket_params)
      if ticket.persisted?
        seat.update(is_taken: true)
        success!(data: ticket)
      else
        fail!(error: ticket.errors.full_messages)
      end
    end
  end
end
