module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorize!, only: %i[show reset_email update_email]
      before_action :authorize_user

      def show
        render json: { user: UserSerializer.new(current_user) },
               status: :ok
      end

      def activate
        result = Users::Email::ActivationService.call(token: params[:token])
        if result.success?
          render json: { message: "Аккаунт #{result.data.email} был успешно активирован" },
                 status: :ok
        else
          render json: { message: "Что-то пошло не так в процессе активации",
                         errors: result.error },
                 status: :unprocessable_entity
        end
      end

      def reset_email
        result = Users::Email::ResetService.call(user: current_user)
        if result.success?
          render json: { message: "Ссылка для сброса e-mail отправлена на #{current_user.email}" },
                 status: :ok
        else
          render json: { message: "Что-то пошло не так",
                         errors: result.error },
                 status: :bad_request
        end
      end

      def update_email
        result = Users::Email::UpdateService.call(
          token: params[:token],
          email: params[:email]
        )
        if result.success?
          render json: { message: "Ссылка для активации нового e-mail отправлена на #{params[:email]}" },
                 status: :ok
        else
          render json: { message: "Что-то пошло не так",
                         errors: result.error },
                 status: :unprocessable_entity
        end
      end

      def reset_password
        result = Users::Password::ResetService.call(email: params[:email])
        if result.success?
          render json: { message: "Ссылка для сброса пароля отправлена на #{params[:email]}" },
                 status: :ok
        else
          render json: { message: "Что-то пошло не так",
                         errors: result.error },
                 status: :bad_request
        end
      end

      def update_password
        result = Users::Password::UpdateService.call(token: params[:token], password: params[:password])
        if result.success?
          render json: { message: "Пароль успешно обновлен" },
                 status: :ok
        else
          render json: { message: "Что-то пошло не так",
                         errors: result.error },
                 status: :unprocessable_entity
        end
      end

      private

      def authorize_user
        authorize(current_user || User)
      end
    end
  end
end
