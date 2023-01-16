module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique

    rescue_from Pundit::NotAuthorizedError, with: :access_forbidden

    protected

    def record_not_found(e)
      render json: { error: e.message },
             status: 404
    end

    def record_not_unique
      render json: { message: 'Seems like record with this data already exists' },
             status: 422
    end
    def access_forbidden
      render json: { message: 'You are not allowed to do this action' },
             status: 403
    end

  end
end
