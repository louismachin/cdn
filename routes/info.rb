get '/info/*' do
    file_path = URI.decode_www_form_component(params['splat'][0])
    full_path = File.join('data', file_path)
    initial_dir = file_path.split('/')[0]
    is_public = initial_dir == 'public'

    protected! unless is_public
    
    unless File.exist?(full_path)
        halt 404, "File or directory not found"
    end

    if File.file?(full_path)
        content_type 'application/json'
        get_file_info(full_path).to_json
    else
        halt 400, "Invalid file type"
    end
end

post '/info/*' do
    file_path = URI.decode_www_form_component(params['splat'][0])
    full_path = File.join('data', file_path)
    initial_dir = file_path.split('/')[0]
    is_public = initial_dir == 'public'
    protected! unless is_public
    
    unless File.exist?(full_path)
        halt 404, "File or directory not found"
    end
    
    unless File.file?(full_path)
        halt 400, "Invalid file type"
    end

    request.body.rewind
    data = JSON.parse(request.body.read)

    unless data.is_a?(Hash)
        halt 400, "Request body must be a JSON object"
    end

    if write_key_values(full_path + '.info', data)
        reset_file_info_cache
        content_type 'application/json'
        { success: true, message: "File updated successfully" }.to_json
    else
        halt 500, "Failed to write file"
    end
rescue JSON::ParserError
    halt 400, "Invalid JSON in request body"
end