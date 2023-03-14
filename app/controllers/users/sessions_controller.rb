module Users
  class SessionsController < ApplicationController
    include UserParamable

    before_action :authorize!, only: [:destroy]

    def create
      result = Auth::AuthenticationService.call(user_params: user_params)
      if result.success?
        access_token, refresh_token = Jwt::TokensGeneratorService.call(user_id: result.data&.id).data
        cookies['refresh_token'] = {
          value: refresh_token,
          expires: Constants::Jwt::JWT_EXPIRATION_TIMES['refresh'],
          httponly: true
        }
        render json: { message: 'You have successfully logged in',
                       access_token: access_token },
               status: :created
      else
        render json: { message: 'Something went wrong',
                       errors: result.error },
               status: :bad_request
      end
    end

    def refresh_tokens
      result = Jwt::TokensRefresherService.call(refresh_token: cookies['refresh_token'])
      if result.success?
        access_token, refresh_token = result.data
        cookies['refresh_token'] = {
          value: refresh_token,
          expires: Constants::Jwt::JWT_EXPIRATION_TIMES['refresh'],
          httponly: true
        }
        render json: { access_token: access_token },
               status: :ok
      else
        render json: { errors: [result.error] },
               status: :unauthorized
      end
    end

    def destroy
      current_user.refresh_token&.destroy
      cookies.delete :refresh_token
      render json: { message: 'You have successfully logged out.' },
             status: :ok
    end
  end
end
