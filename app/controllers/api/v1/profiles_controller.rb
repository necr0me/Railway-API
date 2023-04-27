module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authorize!
      before_action :find_profile, only: %i[update destroy]
      before_action :authorize_profile

      def index
        render json: { profiles: current_user.profiles },
               status: :ok
      end

      def create
        profile = current_user.profiles.create(profile_params)
        if profile.persisted?
          render json: { message: "Profile successfully created",
                         profile: profile },
                 status: :created
        else
          render json: { message: "Something went wrong",
                         errors: profile.errors },
                 status: :unprocessable_entity
        end
      end

      def update
        if @profile.update(profile_params)
          render json: { message: "Profile successfully updated",
                         profile: @profile },
                 status: :ok
        else
          render json: { message: "Something went wrong",
                         errors: @profile.errors },
                 status: :unprocessable_entity
        end
      end

      def destroy
        if @profile.destroy
          render json: { message: "Profile successfully destroyed" },
                 status: :ok
        else
          render json: { message: "Something went wrong",
                         errors: @profile.errors },
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

      def find_profile
        @profile = Profile.find(params[:id].to_i)
      end

      def authorize_profile
        authorize(@profile || Profile)
      end
    end
  end
end
