module Api
  module V1
    class TrainsController < ApplicationController
      before_action :authorize!, except: %i[show_stops]
      before_action :find_train, :authorize_train

      def show
        render json: { train: TrainSerializer.new(@train, { include: %i[carriages] }) },
               status: :ok
      end

      def show_stops
        @pagy, @stops = pagy(@train.stops, page: params[:page] || 1)
        render json: { train: TrainSerializer.new(@train),
                       stops: TrainStopSerializer.new(@stops).serializable_hash.merge(
                         pages: @pagy.pages
                       ) }
      end

      private

      def find_train
        @train = Train.find(params[:train_id].to_i)
      end

      def authorize_train
        authorize(@train || Train)
      end
    end
  end
end
