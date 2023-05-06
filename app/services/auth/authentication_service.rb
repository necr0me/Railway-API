module Auth
  class AuthenticationService < ApplicationService
    def initialize(user_params:)
      @email = user_params[:email]
      @password = user_params[:password]
    end

    def call
      authenticate
    end

    private

    attr_reader :email, :password

    def authenticate
      user = User.find_by(unconfirmed_email: email)
      user ||= User.find_by(email: email)
      return fail!(error: { email: ["Can't find user with such email"] }) if user.nil?
      return fail!(error: { email: ["Account is not activated"] }) unless user.activated?

      user.authenticate(password) ? success!(data: user) : fail!(error: { password: ["Invalid password"] })
    end
  end
end
