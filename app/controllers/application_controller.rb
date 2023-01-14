class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Pundit::Authorization

  # TODO: Rescue from creating record with same id.
  # TODO: Move error handling in separate concern.
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from Pundit::NotAuthorizedError, with: :access_forbidden

  protected
  def authorize!
    @result = Auth::AuthorizationService.call(authorization_header: request.headers['Authorization'])
    if @result.success?
      current_user
    else
      render json: { message: 'You\'re not logged in.',
                     errors: @result.errors },
             status: 401
    end
  end

  def current_user
    @current_user ||= User.find(@result.data['user_id'])
  end

  def record_not_found(e)
    render json: { error: e.message },
           status: 400
  end

  def access_forbidden
    render json: { message: 'You are not allowed to do this action' },
           status: 403
  end
end
