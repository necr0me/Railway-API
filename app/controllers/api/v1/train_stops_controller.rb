module Api
  module V1
    class TrainStopsController < ApplicationController
      before_action :authorize_train_stop

      def index
        result = Trains::FinderService.call(
          departure_station: params[:departure_station],
          arrival_station: params[:arrival_station],
          date: params[:date],
          day_option: params[:day_option]
        )
        if result.success?
          render json: { found_trains: FoundTrainsSerializer.new(result.data).serializable_hash },
                 status: :ok
        else
          render json: { errors: result.error },
                 status: :unprocessable_entity
        end
      end

      private

      def authorize_train_stop
        authorize(TrainStop)
      end
    end
  end
end
