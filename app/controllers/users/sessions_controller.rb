module Users
  class SessionsController < ApplicationController
    include UserParamable

    before_action :authorize!, only: [:destroy]

    def create
      result = Auth::AuthenticationService.call(user_params: user_params)
      if result.success?
        access_token, refresh_token = Jwt::TokensGeneratorService.call(user_id: result.user.id)
        cookies['refresh_token'] = {
          value: refresh_token,
          expires: Constants::Jwt::JWT_EXPIRATION_TIMES['refresh'],
          httponly: true }
        render json: { access_token: access_token },
               status: 201
      else
        render json: { errors: result.errors  },
               status: 400
      end
    end

    def refresh_tokens
      result = Jwt::TokensRefresherService.call(refresh_token: cookies['refresh_token'])
      if result.success?
        access_token, refresh_token = result.tokens
        cookies['refresh_token'] = {
          value: refresh_token,
          expires: Constants::Jwt::JWT_EXPIRATION_TIMES['refresh'],
          httponly: true }
        render json: { access_token: access_token },
               status: 200
      else
        render json: { errors: result.errors },
               status: 401
      end
    end

    def destroy
      current_user.refresh_token.destroy
      cookies.delete :refresh_token
      render json: { message: 'You have successfully logged out.' },
             status: 200
    end
  end
end