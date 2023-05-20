module Api
  module V1
    class StationsController < ApplicationController
      before_action :find_station, only: %i[show]
      before_action :authorize_station

      def index
        @stations = Station.where("name LIKE :prefix", prefix: "#{params[:station]}%")
        @pagy, @stations = pagy(@stations, pagy_options)
        render json: { stations: StationSerializer.new(@stations),
                       pages: @pagy.pages }
      end

      def show
        render json: { station: StationSerializer.new(@station) }
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
          items: params[:page] ? Pagy::DEFAULT[:items] : Station.count,
          page: params[:page] || 1
        }
      end
    end
  end
end
