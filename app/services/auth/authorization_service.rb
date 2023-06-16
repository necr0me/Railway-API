module Auth
  class AuthorizationService < ApplicationService
    include Constants::Jwt

    def initialize(authorization_header:)
      @authorization_header = authorization_header
    end

    def call
      authorize
    end

    private

    attr_reader :authorization_header

    def authorize
      return fail!(error: "Заголовок 'Authorization' не представлен") if authorization_header.nil?

      token = token_from_header
      result = Jwt::DecoderService.call(token: token, type: "access")
      result.success? ? success!(data: result.data&.first) : fail!(error: result.error)
    end

    def token_from_header
      authorization_header.split(" ")[1]
    end
  end
end
