module Api
  module V1
    class TicketsController < ApplicationController
      before_action :find_ticket, only: %i[destroy]
      before_action :authorize!, :authorize_ticket

      def index
        render json: { tickets: TicketSerializer.new(current_user.tickets, ticket_serializer_options) },
               status: :ok
      end

      def create
        result = Tickets::CreatorService.call(tickets_params: tickets_params)
        if result.success?
          render json: { message: "Билеты успешно куплены" },
                 status: :created
        else
          render json: { message: "Что-то пошло не так",
                         errors: [result.error].flatten },
                 status: :unprocessable_entity
        end
      end

      def destroy
        if @ticket.destroy
          render json: { message: "Билет успешно удален" },
                 status: :ok
        else
          render json: { message: "Что-то пошло не так",
                         errors: @ticket.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      def tickets_params
        params.require(:tickets).permit(:departure_stop_id,
                                        :arrival_stop_id,
                                        passengers: %i[seat_id
                                                       profile_id
                                                       price])
      end

      def authorize_ticket
        authorize(@ticket || Ticket)
      end

      def find_ticket
        @ticket = Ticket.find(params[:id].to_i)
      end

      def ticket_serializer_options
        { params: { include_seats: false }, include: %i[seat.carriage profile] }
      end
    end
  end
end
