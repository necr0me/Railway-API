module Users
  class RegistrationsController < ApplicationController
    before_action :authorize!, :find_user, only: :destroy
    before_action :authorize_user

    def create
      result = Users::CreatorService.call(user_params: user_params)
      if result.success?
        render json: { message: "Аккаунт успешно зарегистрирован. " \
                                "Проверьте указанную при регистрации почту для активации аккаунта." },
               status: :created
      else
        render json: { errors: result.error },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @user.destroy
        head :no_content
      else
        render json: { message: "Что-то пошло не так",
                       errors: @user.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:unconfirmed_email, :password)
    end

    def find_user
      @user = User.find(params[:id].to_i)
    end

    def authorize_user
      authorize(@user || User)
    end
  end
end
