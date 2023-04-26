module Admin
  class TicketsController < AdminController
    before_action :find_ticket, only: %i[show destroy]
    before_action :authorize_ticket

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

    def authorize_ticket
      authorize(@ticket || Ticket)
    end

    def find_ticket
      @ticket = Ticket.find(params[:id])
    end
  end
end

