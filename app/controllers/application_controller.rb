class ApplicationController < ActionController::API
  include ActionController::Cookies
  # TODO: Rescue from creating record with same id.
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

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
end
