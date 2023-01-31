module Api
  module V1
    class TrainsController < ApplicationController
      before_action :authorize!
      before_action :find_train, except: %i[index create]

      def index
        trains = Train.all
        authorize trains
        render json: { trains: Train.all },
               status: 200
      end

      def show
        authorize @train
        render json: { train: @train },
               status: 200
      end

      def create
        train = Train.create(route_id: params.dig(:train, :route_id))
        authorize train
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
        authorize @train
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
        authorize @train
        result = Trains::CarriageAdderService.call(train: @train,
                                                   carriage_id: params[:carriage_id])
        if result.success?
          render json: { message: 'Carriage was successfully added to train',
                         carriage: result.data },
                 status: 200
        else
          render json: { message: 'Something went wrong',
                         errors: [result.error] },
                 status: 422
        end
      end

      def remove_carriage
        authorize @train
        result = Trains::CarriageRemoverService.call(train: @train,
                                                     carriage_id: params[:carriage_id])
        if result.success?
          render json: { message: 'Carriage was successfully removed from train' },
                 status: 200
        else
          render json: { message: 'Something went wrong',
                         errors: [result.error] },
                 status: 422
        end
      end

      def destroy
        authorize @train
        if  @train.destroy
          head 204
        else
          render json: { message: 'Something went wrong',
                         errors: @train.errors.full_messages },
                 status: 422
        end
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

