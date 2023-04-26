module Admin
  class PassingTrainsController < AdminController
    before_action :find_passing_train, only: %i[update destroy]
    before_action :authorize_passing_train

    def create
      passing_train = PassingTrain.create(passing_train_params)
      if passing_train.persisted?
        render json: { message: "Train stop successfully created",
                       passing_train: PassingTrainSerializer.new(passing_train) },
               status: :created
      else
        render json: { message: "Something went wrong",
                       errors: passing_train.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    def update
      if @passing_train.update(passing_train_params)
        render json: { message: "Train stop successfully updated",
                       passing_train: PassingTrainSerializer.new(@passing_train) },
               status: :ok
      else
        render json: { message: "Something went wrong",
                       errors: @passing_train.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @passing_train.destroy
        render json: { message: "Train stop successfully removed" },
               status: :ok
      else
        render json: { message: "Something went wrong",
                       errors: @passing_train.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    private

    def passing_train_params
      params.require(:passing_train).permit(:train_id,
                                            :station_id,
                                            :way_number,
                                            :arrival_time,
                                            :departure_time)
    end

    def find_passing_train
      @passing_train = PassingTrain.find(params[:id].to_i)
    end

    def authorize_passing_train
      authorize(@passing_train || PassingTrain)
    end
  end
end
