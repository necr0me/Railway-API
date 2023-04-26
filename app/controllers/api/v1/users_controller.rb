module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorize!, :find_user, :authorize_user

      def show
        render json: { user: @user },
               status: :ok
      end

      def update
        if @user.update(password: params[:user][:password]) # User able to update only his password
          render json: { message: "You have successfully updated your credentials" },
                 status: :ok
        else
          render json: { message: "Something went wrong",
                         errors: @user.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      def find_user
        @user = User.find(params[:id])
      end

      def authorize_user
        authorize(@user || User)
      end
    end
  end
end
