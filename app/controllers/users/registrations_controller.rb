module Users
  class RegistrationsController < ApplicationController
    include UserFindable, UserParamable

    before_action :authorize!, :find_user, only: :destroy

    def create
      user = User.create(user_params)
      if user.persisted?
        render json: { message: 'You have successfully registered' },
               status: 201
      else
        render json: { errors: user.errors.full_messages },
               status: 422
      end
    end

    # TODO: Add 'if-else' block for handling errors during destroy
    def destroy
      authorize @user
      @user.destroy
      head 204
    end
  end
end
