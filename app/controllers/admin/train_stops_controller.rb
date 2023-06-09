module Admin
  class TrainStopsController < AdminController
    before_action :find_train_stop, only: %i[update destroy]
    before_action :authorize_train_stop

    def create
      train_stop = TrainStop.create(train_stop_params)
      if train_stop.persisted?
        render json: { message: "Остановка успешно создана",
                       train_stop: TrainStopSerializer.new(train_stop) },
               status: :created
      else
        render json: { message: "Что-то пошло не так",
                       errors: train_stop.errors },
               status: :unprocessable_entity
      end
    end

    def update
      if @train_stop.update(train_stop_params)
        render json: { message: "Остановка успешно обновлена",
                       train_stop: TrainStopSerializer.new(@train_stop) },
               status: :ok
      else
        render json: { message: "Что-то пошло не так",
                       errors: @train_stop.errors },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @train_stop.destroy
        render json: { message: "Остановка успешно удалена" },
               status: :ok
      else
        render json: { message: "Что-то пошло не так",
                       errors: @train_stop.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    private

    def train_stop_params
      params.require(:train_stop).permit(:train_id,
                                         :station_id,
                                         :way_number,
                                         :arrival_time,
                                         :departure_time)
    end

    def find_train_stop
      @train_stop = TrainStop.find(params[:id].to_i)
    end

    def authorize_train_stop
      authorize(@train_stop || TrainStop)
    end
  end
end
