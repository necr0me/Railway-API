module Admin
  class CarriageTypesController < AdminController
    before_action :find_carriage_type, only: %i[update destroy]
    before_action :authorize_carriage_type

    def index
      @pagy, @types = pagy(CarriageType.all, pagy_options)
      render json: { carriage_types: CarriageTypeSerializer.new(@types),
                     pages: @pagy.pages },
             status: :ok
    end

    def create
      carriage_type = CarriageType.create(carriage_type_params)
      if carriage_type.persisted?
        render json: { message: "Carriage type successfully created",
                       carriage_type: CarriageTypeSerializer.new(carriage_type) },
               status: :created
      else
        render json: { message: "Something went wrong",
                       errors: carriage_type.errors },
               status: :unprocessable_entity
      end
    end

    def update
      result = CarriageTypes::UpdaterService.call(
        carriage_type: @carriage_type,
        carriage_type_params: carriage_type_params
      )
      if result.success?
        render json: { message: "Carriage type successfully updated",
                       carriage_type: CarriageTypeSerializer.new(result.data) },
               status: :ok
      else
        render json: { message: "Something went wrong",
                       errors: result.error },
               status: :unprocessable_entity
      end
    end

    def destroy
      result = CarriageTypes::DestroyerService.call(carriage_type: @carriage_type)
      if result.success?
        head :no_content
      else
        render json: { message: "Something went wrong",
                       errors: [result.error] },
               status: :unprocessable_entity
      end
    end

    private

    def carriage_type_params
      params.require(:carriage_type).permit(:name, :description, :capacity)
    end

    def find_carriage_type
      @carriage_type = CarriageType.find(params[:id])
    end

    def authorize_carriage_type
      authorize(@carriage_type || CarriageType)
    end

    def pagy_options
      {
        items: params[:page] ? Pagy::DEFAULT[:items] : CarriageType.count,
        page: params[:page] || 1
      }
    end
  end
end

