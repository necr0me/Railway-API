module Api
  module V1
    class TicketsController < ApplicationController
      before_action :find_ticket, only: %i[destroy]
      before_action :authorize!, :authorize_ticket

      def index
        render json: { tickets: current_user.tickets },
               status: :ok
      end

      def create
        result = Tickets::CreatorService.call(tickets_params: tickets_params)
        if result.success?
          render json: { message: "Tickets successfully created" },
                 status: :created
        else
          render json: { message: "Something went wrong",
                         errors: [result.error].flatten },
                 status: :unprocessable_entity
        end
      end

      def destroy
        if @ticket.destroy
          render json: { message: "Ticket successfully destroyed" },
                 status: :ok
        else
          render json: { message: "Something went wrong",
                         errors: @ticket.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      def tickets_params
        params.require(:tickets).permit(:departure_station_id,
                                        :arrival_station_id,
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
    end
  end
end
