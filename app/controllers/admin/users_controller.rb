module Admin
  class UsersController < AdminController
    before_action :find_user, :authorize_user

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

    def find_user
      @user = User.find(params[:id].to_i)
    end

    def authorize_user
      authorize(@user || User)
    end
  end
end
