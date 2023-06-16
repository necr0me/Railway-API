module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authorize!
      before_action :find_profile, only: %i[update destroy]
      before_action :authorize_profile

      def index
        render json: { profiles: ProfileSerializer.new(current_user.profiles) },
               status: :ok
      end

      def create
        profile = current_user.profiles.create(profile_params)
        if profile.persisted?
          render json: { message: "Пассажир успешно добавлен",
                         profile: ProfileSerializer.new(profile) },
                 status: :created
        else
          render json: { message: "Что-то пошло не так",
                         errors: profile.errors.to_hash(full_messages: true) },
                 status: :unprocessable_entity
        end
      end

      def update
        if @profile.update(profile_params)
          render json: { message: "Информация о пассажире успешно обновлена",
                         profile: ProfileSerializer.new(@profile) },
                 status: :ok
        else
          render json: { message: "Что-то пошло не так",
                         errors: @profile.errors.to_hash(full_messages: true) },
                 status: :unprocessable_entity
        end
      end

      def destroy
        if @profile.destroy
          render json: { message: "Пассажир успешно удален" },
                 status: :ok
        else
          render json: { message: "Что-то пошло не так",
                         errors: @profile.errors.full_messages },
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
