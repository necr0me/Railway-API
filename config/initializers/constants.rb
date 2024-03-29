module Constants
  module Jwt
    JWT_SECRET_KEYS = {
      "access" => Rails.application.credentials.jwt[:secret_access_key],
      "refresh" => Rails.application.credentials.jwt[:secret_refresh_key]
    }
    JWT_EXPIRATION_TIMES = {
      "access" => 2.hours,
      "refresh" => 30.days
    }
    JWT_ALGORITHM = "HS256"
  end

  module Url
    FRONT_END = {
      "development" => "http://localhost:5173",
      "production" => "https://railway-tickets.onrender.com"
    }
  end
end
