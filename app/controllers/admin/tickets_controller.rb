module Admin
  class TicketsController < AdminController
    before_action :find_ticket, :authorize_ticket

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

    def authorize_ticket
      authorize(@ticket || Ticket)
    end

    def find_ticket
      @ticket = Ticket.find(params[:id].to_i)
    end
  end
end
