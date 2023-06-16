module Admin
  class CarriagesController < AdminController
    before_action :find_carriage, only: %i[show update destroy]
    before_action :authorize_carriage

    def index
      @carriages = Carriage.search(params[:carriage])
      @pagy, @carriages = pagy(@carriages, page: params[:page] || 1)
      render json: { carriages: CarriageSerializer.new(@carriages, { params: { include_seats: false } }),
                     pages: @pagy.pages },
             status: :ok
    end

    def show
      render json: { carriage: CarriageSerializer.new(@carriage, serializer_options) },
             status: :ok
    end

    def create
      carriage = Carriage.create(carriage_params)
      if carriage.persisted?
        render json: { message: "Вагон успешно создан",
                       carriage: CarriageSerializer.new(carriage) },
               status: :created
      else
        render json: { message: "Что-то пошло не так",
                       errors: carriage.errors.to_hash(full_messages: true) },
               status: :unprocessable_entity
      end
    end

    def update
      if @carriage.update(name: params.dig(:carriage, :name))
        render json: { message: "Название вагона успешно обновлено",
                       carriage: CarriageSerializer.new(@carriage) },
               status: :ok
      else
        render json: { message: "Что-то пошло не так",
                       errors: @carriage.errors.to_hash(full_messages: true) },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @carriage.destroy
        head :no_content
      else
        render json: { message: "Что-то пошло не так",
                       errors: @carriage.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    private

    def carriage_params
      params.require(:carriage).permit(:name, :carriage_type_id)
    end

    def find_carriage
      @carriage = Carriage.find(params[:id].to_i)
    end

    def authorize_carriage
      authorize(@carriage || Carriage)
    end

    def serializer_options
      { include: %i[seats seats.ticket seats.ticket.profile], params: { include_ticket: true, include_seats: true } }
    end
  end
end
