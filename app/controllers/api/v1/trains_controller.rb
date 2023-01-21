module Api
  module V1
    class TrainsController < ApplicationController
      before_action :authorize!
      before_action :find_train, except: %i[index create]

      def index
        render json: { trains: Train.all },
               status: 200
      end

      def show
        render json: { train: @train },
               status: 200
      end

      def create
        train = Train.create(train_params)
        if train.persisted?
          render json: { message: 'Train was successfully created',
                         train: train },
                 status: 201
        else
          render json: { message: 'Something went wrong',
                         errors: train.errors.full_messages },
                 status: 422
        end
      end

      def update
        if @train.update(train_params)
          render json: { message: 'Train was successfully updated',
                         train: @train },
                 status: 200
        else
          render json: { message: 'Something went wrong',
                         errors: @train.errors.full_messages },
                 status: 422
        end
      end

      def add_carriage
        result = Trains::CarriageAdderService.call(train: @train,
                                                   carriage_id: params[:carriage_id])
        if result.success?
          render json: { message: 'Carriage was successfully added to train',
                         carriage: result.data },
                 status: 200
        else
          render json: { message: 'Something went wrong',
                         errors: result.errors },
                 status: 422
        end
      end

      def remove_carriage
        result = Trains::CarriageRemoverService.call(train: @train,
                                                     carriage_id: params[:carriage_id])
        if result.success?
          render json: { message: 'Carriage was successfully removed from train' },
                 status: 200
        else
          render json: { message: 'Something went wrong',
                         errors: result.errors },
                 status: 422
        end
      end

      def destroy
        @train.destroy
        head 204
      end

      private

      def train_params
        params.require(:train).permit(:route_id)
      end

      def find_train
        @train ||= Train.find(params[:train_id])
      end
    end
  end
end

