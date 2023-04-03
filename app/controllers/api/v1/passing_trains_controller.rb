module Api
  module V1
    class PassingTrainsController < ApplicationController
      before_action :authorize!, except: %i[index]
      before_action :find_passing_train, only: %i[update destroy]
      before_action :authorize_passing_train

      def index
        render json: { passing_trains: PassingTrain.all }
      end

      def create
        passing_train = PassingTrain.create(passing_train_params)
        if passing_train.persisted?
          render json: { message: "Train stop successfully created",
                         passing_train: passing_train },
                 status: :created
        else
          render json: { message: "Something went wrong",
                         errors: passing_train.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def update
        if @passing_train.update(passing_train_params)
          render json: { message: "Train stop successfully updated",
                         passing_train: @passing_train },
                 status: :ok
        else
          render json: { message: "Something went wrong",
                         errors: @passing_train.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def destroy
        if @passing_train.destroy
          render json: { message: "Train stop successfully removed" },
                 status: :ok
        else
          render json: { message: "Something went wrong",
                         errors: @passing_train.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      def find_passing_train
        @passing_train = PassingTrain.find(params[:id])
      end

      def passing_train_params
        params.require(:passing_train).permit(:train_id,
                                              :station_id,
                                              :way_number,
                                              :arrival_time,
                                              :departure_time)
      end

      def authorize_passing_train
        authorize(@passing_train || PassingTrain)
      end
    end
  end
end
