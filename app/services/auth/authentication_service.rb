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
      user = User.find_by(email: email)
      user ||= User.find_by(unconfirmed_email: email)
      return fail!(error: { email: ["Пользователя с таким email не существует"] }) if user.nil?
      return fail!(error: { email: ["Аккаунт не активирован"] }) unless user.activated?
      return fail!(error: { email: ["E-mail не подтвержден"] }) if user.activated? && user.unconfirmed_email == email

      user.authenticate(password) ? success!(data: user) : fail!(error: { password: ["Неверный пароль"] })
    end
  end
end
