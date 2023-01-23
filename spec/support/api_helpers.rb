module ApiHelpers
  def json_response
    JSON.parse(response.body)
  end

  def login_with_api(credentials)
    post '/users/login',
         params: {
           user: credentials
         }
  end

  def auth_header
    { Authorization: "Bearer #{json_response['access_token']}" }
  end
end
