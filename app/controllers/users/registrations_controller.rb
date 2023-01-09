module Users
  class RegistrationsController < ApplicationController
    include UserFindable
    include UserParamable

    before_action :find_user, only: :destroy

    def create
      user = User.create(user_params)
      if user.persisted?
        render json: {
          status: 201,
          message: 'You have successfully registered'
        }
      else
        render json: {
          status: 422,
          errors: user.errors.full_messages
        }
      end
    end

    def destroy
      @user.destroy
      head 204
    end
  end
end
