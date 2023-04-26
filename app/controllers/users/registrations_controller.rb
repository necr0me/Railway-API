module Users
  class RegistrationsController < ApplicationController
    before_action :authorize!, :find_user, only: :destroy
    before_action :authorize_user

    def create
      user = User.create(user_params)
      if user.persisted?
        render json: { message: "You have successfully registered" },
               status: :created
      else
        render json: { errors: user.errors },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @user.destroy
        head :no_content
      else
        render json: { message: "Something went wrong",
                       errors: @user.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :password)
    end

    def find_user
      @user = User.find(params[:id])
    end

    def authorize_user
      authorize(@user || User)
    end
  end
end
