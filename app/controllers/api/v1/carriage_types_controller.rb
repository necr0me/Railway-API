module Api
  module V1
    class CarriageTypesController < ApplicationController
      before_action :authorize!
      before_action :find_carriage_type, only: %i[update destroy]

      def index
        types = CarriageType.all
        authorize types
        render json: { carriage_types: types },
               status: :ok
      end

      def create
        carriage_type = CarriageType.create(carriage_type_params)
        authorize carriage_type
        if carriage_type.persisted?
          render json: { message: 'Carriage type successfully created',
                         carriage_type: carriage_type },
                 status: :created
        else
          render json: { message: 'Something went wrong',
                         errors: carriage_type.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def update
        authorize @carriage_type
        result = CarriageTypes::UpdaterService.call(
          carriage_type: @carriage_type,
          carriage_type_params: carriage_type_params
        )
        if result.success?
          render json: { message: 'Carriage type successfully updated',
                         carriage_type: result.data },
                 status: :ok
        else
          render json: { message: 'Something went wrong',
                         errors: [result.error] },
                 status: :unprocessable_entity
        end
      end

      def destroy
        authorize @carriage_type
        result = CarriageTypes::DestroyerService.call(carriage_type: @carriage_type)
        if result.success?
          head :no_content
        else
          render json: { message: 'Something went wrong',
                         errors: [result.error] },
                 status: :unprocessable_entity
        end
      end

      private

      def carriage_type_params
        params.require(:carriage_type).permit(:name, :description, :capacity)
      end

      def find_carriage_type
        @carriage_type = CarriageType.find(params[:id])
      end
    end
  end
end
