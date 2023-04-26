module Api
  module V1
    class TrainsController < ApplicationController
      before_action :authorize!, :find_train, :authorize_train

      def show
        render json: { train: TrainSerializer.new(@train, { include: %i[carriages stops] }) },
               status: :ok
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
