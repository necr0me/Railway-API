module Api
  module V1
    class StationsController < ApplicationController
      before_action :authorize!, except: %i[index]
      before_action :find_station, only: %i[show update destroy]

      def index
        render json: Station.where('name LIKE :prefix', prefix: "#{params[:station]}%")
      end

      def show
        render json: @station
      end

      def create
        station = Station.create(station_params)
        if station.persisted?
          render json: { station: station },
                 status: 201
        else
          render json: { message: 'Something went wrong',
                         errors: station.errors.full_messages },
                 status: 422
        end
      end

      def update
        if @station.update(station_params)
          render json: { station: @station },
                 status: 200
        else
          render json: { message: 'Something went wrong',
                         errors: @station.errors.full_messages },
                 status: 422
        end
      end

      def destroy
        @station.destroy
        head 204
      end

      private

      def station_params
        params.require(:station).permit(:name)
      end

      def find_station
        @station ||= Station.find(params[:id])
      end
    end
  end
end
