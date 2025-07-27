helpers do
  def is_valid_attempt?(attempt)
    return $env.check_attempt(attempt)
  end

  def is_logged_in?
    cookie = request.cookies[$env.cookie_name]
    cookie && $env.given_tokens.include?(cookie)
  end

  def protected!
    redirect '/login' unless is_logged_in?
  end
end

get '/login' do
  erb :login
end

post '/login' do
  data = JSON.parse(request.body.read)
  puts data.inspect
  attempt = { password: data['password'] }
  if is_valid_attempt?(attempt)
    token = $env.new_token
    response.set_cookie($env.cookie_name, value: token, path: '/', max_age: '3600')
    content_type :json
    status 200
    { success: true, token: token }.to_json
  else
    content_type :json
    status 401
    { success: false, error: "Invalid password" }.to_json
  end
end

get '/logout' do
  token = request.cookies[$env.cookie_name]
  $env.given_tokens.delete(token) if token
  response.delete_cookie($env.cookie_name, path: '/')
  redirect '/'
end