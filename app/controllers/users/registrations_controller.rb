module Users
  class RegistrationsController < ApplicationController
    include UserParamable
    include UserFindable

    before_action :authorize!, :find_user, only: :destroy

    def create
      user = User.create(user_params)
      if user.persisted?
        render json: { message: 'You have successfully registered' },
               status: :created
      else
        render json: { errors: user.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    def destroy
      authorize @user
      if @user.destroy
        head :no_content
      else
        render json: { message: 'Something went wrong',
                       errors: @user.errors.full_messages },
               status: :unprocessable_entity
      end
    end
  end
end
