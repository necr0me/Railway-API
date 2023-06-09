module Authorization
  extend ActiveSupport::Concern

  included do
    protected

    def authorize!
      @result = Auth::AuthorizationService.call(authorization_header: request.headers["Authorization"])
      if @result.success?
        current_user
      else
        render json: { message: "Вы не авторизованы",
                       errors: [@result.error] },
               status: :unauthorized
      end
    end

    def current_user
      @current_user ||= @result&.data.present? ? User.find(@result.data["user_id"]) : nil
    end
  end
end
