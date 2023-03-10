module Jwt
  class DecoderService < ApplicationService
    include Constants::Jwt

    def initialize(token:, type:)
      @token = token
      @type = type
    end

    def call
      decode(token, type)
    end

    private

    attr_reader :token, :type

    def decode(token, type)
      decoded = JWT.decode(
        token,
        JWT_SECRET_KEYS[type],
        true,
        { alg: JWT_ALGORITHM }
      )
      success!(data: decoded)
    end
  end
end
