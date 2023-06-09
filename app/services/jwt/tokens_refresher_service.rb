module Jwt
  class TokensRefresherService < ApplicationService
    def initialize(refresh_token:)
      @refresh_token = refresh_token
    end

    def call
      refresh_tokens
    end

    private

    attr_reader :refresh_token

    def refresh_tokens
      decode_result = Jwt::DecoderService.call(token: refresh_token, type: "refresh")
      return fail!(error: decode_result.error) if decode_result.data.nil?

      user_id = decode_result.data&.first&.[]("user_id")
      user = User.includes(:refresh_token).find(user_id)
      return fail!(error: "Токены не совпадают") if user.refresh_token.value != refresh_token

      tokens_result = TokensGeneratorService.call(user_id: user_id)
      tokens_result.success? ? success!(data: tokens_result.data) : fail!(error: tokens_result.error)
    end
  end
end
