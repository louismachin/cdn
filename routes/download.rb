download_file = proc do
    protected!
    file_path = params['splat'][0]
    full_path = File.join('data', file_path)
    if File.exist?(full_path)
        send_file full_path
    else
        halt 404, "File not found"
    end
end

get '/download/*', &download_file
get '/dl/*', &download_file