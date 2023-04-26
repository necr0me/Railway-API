module Api
  module V1
    class CarriagesController < ApplicationController
      before_action :authorize!, :find_carriage, :authorize_carriage

      def show
        render json: { carriage: CarriageSerializer.new(@carriage, { include: %i[seats] }) },
               status: :ok
      end

      private

      def find_carriage
        @carriage = Carriage.find(params[:id])
      end

      def authorize_carriage
        authorize(@carriage || Carriage)
      end
    end
  end
end
