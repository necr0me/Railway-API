module Api
  module V1
    class UsersController < ApplicationController
      include UserFindable
      before_action :authorize!, :find_user

      def show
        authorize @user
        render json: { user: @user },
               status: 200
      end

      def update
        authorize @user
        if @user.update(password: params[:user][:password]) # User able to update only his password
          render json: { message: 'You have successfully updated your credentials' },
                 status: 200
        else
          render json: { message: 'Something went wrong',
                         errors: @user.errors.full_messages },
                 status: 422
        end
      end
    end
  end
end

