module Jwt
  class EncoderService < ApplicationService
    include Constants::Jwt

    def initialize(payload:, type:)
      @payload = payload
      @type = type
    end

    def call
      encode(payload, type)
    end

    private

    attr_reader :payload, :type

    def encode(payload, type)
      payload = payload.merge(jwt_data)
      encoded = JWT.encode(
        payload,
        JWT_SECRET_KEYS[type],
        JWT_ALGORITHM
      )
      success!(data: encoded)
    end

    def jwt_data
      {
        exp: JWT_EXPIRATION_TIMES[type].from_now.to_i,
        iat: Time.now.to_i
      }
    end
  end
end
