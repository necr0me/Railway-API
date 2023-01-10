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
end
