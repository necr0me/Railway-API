module Api
  module V1
    class StationsController < ApplicationController
      before_action :authorize!, except: %i[index show]
      before_action :find_station, only: %i[show update destroy]

      def index
        render json: Station.where('name LIKE :prefix', prefix: "#{params[:station]}%")
      end

      def show
        render json: @station
      end

      def create
        station = Station.create(station_params)
        authorize station
        if station.persisted?
          render json: { station: station },
                 status: :created
        else
          render json: { message: 'Something went wrong',
                         errors: station.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def update
        authorize @station
        if @station.update(station_params)
          render json: { station: @station },
                 status: :ok
        else
          render json: { message: 'Something went wrong',
                         errors: @station.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def destroy
        authorize @station
        if @station.destroy
          head :no_content
        else
          render json: { message: 'Something went wrong',
                         errors: @station.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      def station_params
        params.require(:station).permit(:name)
      end

      def find_station
        @station = Station.find(params[:id])
      end
    end
  end
end
