get '/' do
    protected!
    redirect '/view'
end

get '/help' do
    erb :help
end

get '/robots.txt' do
    content_type 'text/plain'
    <<~ROBOTS
        User-agent: *
        Disallow: /
    ROBOTS
end