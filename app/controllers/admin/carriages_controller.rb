module Admin
  class CarriagesController < AdminController
    before_action :find_carriage, only: %i[show update destroy]
    before_action :authorize_carriage

    def index
      @pagy, @carriages = pagy(Carriage.all, page: params[:page] || 1)
      render json: { carriages: CarriageSerializer.new(@carriages),
                     pages: @pagy.pages },
             status: :ok
    end

    def show
      render json: { carriage: CarriageSerializer.new(@carriage, { include: %i[seats] }) },
             status: :ok
    end

    def create
      carriage = Carriage.create(carriage_params)
      if carriage.persisted?
        render json: { message: "Carriage was successfully created",
                       carriage: CarriageSerializer.new(carriage) },
               status: :created
      else
        render json: { message: "Something went wrong",
                       errors: carriage.errors },
               status: :unprocessable_entity
      end
    end

    def update
      if @carriage.update(name: params.dig(:carriage, :name))
        render json: { message: "Carriage name was successfully updated",
                       carriage: CarriageSerializer.new(@carriage) },
               status: :ok
      else
        render json: { message: "Something went wrong",
                       errors: @carriage.errors },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @carriage.destroy
        head :no_content
      else
        render json: { message: "Something went wrong",
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
  end
end
