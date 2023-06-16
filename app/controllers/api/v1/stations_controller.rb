module Api
  module V1
    class StationsController < ApplicationController
      before_action :find_station, only: %i[show]
      before_action :authorize_station

      def index
        @stations = Station.search(params[:station])
        @pagy, @stations = pagy(@stations, pagy_options)
        render json: { stations: StationSerializer.new(@stations),
                       pages: @pagy.pages }
      end

      def show
        @pagy, @stops = pagy(@station.train_stops.arrives_after(Time.now.utc), page: params[:page] || 1)
        render json: { station: StationSerializer.new(@station),
                       stops: TrainStopSerializer.new(@stops).serializable_hash.merge(
                         pages: @pagy.pages
                       ) }
      end

      private

      def find_station
        @station = Station.find(params[:id].to_i)
      end

      def authorize_station
        authorize(@station || Station)
      end

      def pagy_options
        {
          items: params[:page] ? Pagy::DEFAULT[:items] : [Station.count, 1].max,
          page: params[:page] || 1
        }
      end
    end
  end
end
