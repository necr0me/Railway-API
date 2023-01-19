module Api
  module V1
    class CarriagesController < ApplicationController
      before_action :authorize!
      before_action :find_carriage, only: %i[show update destroy]

      def index
        carriages = Carriage.all
        authorize carriages
        render json: { carriages: carriages },
               status: 200
      end

      def show
        authorize @carriage
        render json: { carriage: @carriage },
               status: 200
      end

      def create
        carriage = Carriage.create(carriage_params)
        if carriage.persisted?
          render json: { message: 'Carriage was successfully created',
                         carriage: carriage},
                 status: 201
        else
          render json: { message: 'Something went wrong',
                         errors: carriage.errors.full_messages },
                 status: 422
        end
      end

      def update
        authorize @carriage
        if @carriage.update(name: params.dig(:carriage, :name))
          render json: { message: 'Carriage name was successfully updated',
                         carriage: @carriage },
                 status: 200
        else
          render json: { message: 'Something went wrong',
                         errors: @carriage.errors.full_messages },
                 status: 422
        end
      end

      # TODO: Add 'if-else' block for handling errors during destroy
      def destroy
        authorize @carriage
        @carriage.destroy
        head 204
      end

      private

      def carriage_params
        params.require(:carriage).permit(:name, :carriage_type_id)
      end

      def find_carriage
        @carriage ||= Carriage.find(params[:id])
      end
    end
  end
end

