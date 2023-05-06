module Users
  class TokenGeneratorService < ApplicationService
    def initialize; end

    def call
      success!(data: SecureRandom.hex(16))
    end
  end
end
