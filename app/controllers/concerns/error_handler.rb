module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique
    rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

    rescue_from Pundit::NotAuthorizedError, with: :access_forbidden

    protected

    def record_not_found(error)
      render json: { message: error.message },
             status: :not_found
    end

    def record_not_unique
      render json: { message: "Похоже, что запись с такими же атрибутами уже существует" },
             status: :unprocessable_entity
    end

    def invalid_foreign_key
      render json: { message: "Похоже, что данная запись не существует" },
             status: :unprocessable_entity
    end

    def access_forbidden
      render json: { message: "Вы не можете совершить данное действие" },
             status: :forbidden
    end
  end
end
