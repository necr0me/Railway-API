module Jwt
  class TokensGeneratorService < ApplicationService
    def initialize(user_id:)
      @user_id = user_id
    end

    def call
      generate_tokens
    end

    private

    attr_reader :user_id

    def generate_tokens
      access_token = Jwt::EncoderService.call(payload: payload, type: "access")
      return fail!(error: access_token.error) if access_token.data.nil?

      refresh_token = Jwt::EncoderService.call(payload: payload, type: "refresh")
      return fail!(error: refresh_token.error) if refresh_token.data.nil?

      create_or_update_refresh_token(refresh_token)
      success!(data: [access_token.data, refresh_token.data])
    end

    def create_or_update_refresh_token(refresh_token)
      if user.refresh_token.present?
        user.refresh_token.update(value: refresh_token.data)
      else
        user.create_refresh_token(value: refresh_token.data)
      end
    end

    def user
      @user ||= User.includes(:refresh_token).find(user_id)
    end

    def payload
      {
        user_id: user_id,
        admin: user&.role == :admin.to_s
      }
    end
  end
end
