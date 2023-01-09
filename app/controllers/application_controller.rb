class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def record_not_found(e)
    render json: {
      error: e.message
    }, status: 400
  end
end
