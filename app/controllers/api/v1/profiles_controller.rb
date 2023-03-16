module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authorize!

      def show
        render json: { profile: current_user.profile }
      end

      def create
        profile = current_user.create_profile(profile_params)
        if profile.persisted?
          render json: { profile: current_user.profile },
                 status: :created
        else
          render json: { message: 'Something went wrong',
                         errors: profile.errors },
                 status: :unprocessable_entity
        end
      end

      def update
        if current_user.profile.update(profile_params)
          render json: { profile: current_user.profile },
                 status: :ok
        else
          render json: { message: 'Something went wrong',
                         errors: current_user.profile.errors },
                 status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.require(:profile).permit(
          :name,
          :surname,
          :patronymic,
          :phone_number,
          :passport_code
        )
      end
    end
  end
end
