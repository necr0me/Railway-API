module Api
  module V1
    class UsersController < ApplicationController
      include UserFindable, UserParamable
      before_action :authorize!, :find_user

      def show
        render json: @user
      end

      def update
        if @user.update(user_params)
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

