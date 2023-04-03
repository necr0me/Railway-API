module Api
  module V1
    class TicketsController < ApplicationController
      before_action :find_ticket, only: %i[show destroy]
      before_action :authorize!, :authorize_ticket

      def show
        render json: { ticket: @ticket }, # TODO: implement serializer
               status: :ok
      end

      def create
        result = Tickets::CreatorService.call(ticket_params: ticket_params)
        if result.success?
          render json: { message: "Ticket successfully created",
                         ticket: result.data },
                 status: :created
        else
          render json: { message: "Something went wrong", # TODO: try to move this block in concern or AppController
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

      def ticket_params
        params.require(:ticket).permit(:price,
                                       :user_id,
                                       :seat_id,
                                       :departure_station_id,
                                       :arrival_station_id)
      end

      def authorize_ticket
        authorize(@ticket || Ticket)
      end

      def find_ticket
        @ticket = Ticket.find(params[:id])
      end
    end
  end
end
