module Admin
  class TrainsController < AdminController
    before_action :find_train, only: %i[show update add_carriage remove_carriage destroy]
    before_action :authorize_train

    def index
      @pagy, @trains = pagy(Train.all, page: params[:page] || 1)
      render json: { trains: TrainSerializer.new(@trains),
                     pages: @pagy.pages },
             status: :ok
    end

    def show
      render json: { train: TrainSerializer.new(@train, { include: %i[carriages route.stations stops] }),
                     available_carriages: CarriageTypeSerializer.new(
                       CarriageType.all, { include: [:carriages] }
                     ) },
             status: :ok
    end

    def create
      train = Train.create(route_id: params.dig(:train, :route_id))
      if train.persisted?
        render json: { message: "Train was successfully created",
                       train: TrainSerializer.new(train) },
               status: :created
      else
        render json: { message: "Something went wrong",
                       errors: train.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    def update
      if @train.update(train_params)
        render json: { message: "Train was successfully updated",
                       train: @train },
               status: :ok
      else
        render json: { message: "Something went wrong",
                       errors: @train.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    def add_carriage
      result = Trains::CarriageAdderService.call(
        train: @train,
        carriage_id: params[:carriage_id]
      )
      if result.success?
        render json: { message: "Carriage was successfully added to train",
                       carriage: CarriageSerializer.new(result.data) },
               status: :ok
      else
        render json: { message: "Something went wrong",
                       errors: [result.error] },
               status: :unprocessable_entity
      end
    end

    def remove_carriage
      result = Trains::CarriageRemoverService.call(
        train: @train,
        carriage_id: params[:carriage_id]
      )
      if result.success?
        render json: { message: "Carriage was successfully removed from train",
                       carriage: CarriageSerializer.new(result.data) },
               status: :ok
      else
        render json: { message: "Something went wrong",
                       errors: [result.error] },
               status: :unprocessable_entity
      end
    end

    def destroy
      result = Trains::DestroyerService.call(train: @train)
      if result.success?
        head :no_content
      else
        render json: { message: "Something went wrong",
                       errors: result.error.full_messages },
               status: :unprocessable_entity
      end
    end

    private

    def train_params
      params.require(:train).permit(:route_id)
    end

    def find_train
      @train = Train.find(params[:train_id].to_i)
    end

    def authorize_train
      authorize(@train || Train)
    end
  end
end
