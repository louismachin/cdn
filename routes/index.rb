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

get '/disk_space.json' do
    content_type :json
    space = disk_space
    { used: space[:used], free: space[:free] }.to_json
end