class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Pundit::Authorization

  include Authorization
  include ErrorHandler

  include Pagy::Backend
end
