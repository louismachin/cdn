get '/info/*' do
    halt 400, 'Invalid file type' unless File.file?(@path)
    content_type :json
    get_file_info(@path).to_json
end

post '/info/*' do
    protected! # remove only if anonymous users should edit public metadata (see below)
    halt 400, 'Invalid file type' unless File.file?(@path)

    data = JSON.parse(request.body.read)
    halt 400, 'Request body must be a JSON object' unless data.is_a?(Hash)
    halt 400, 'Keys and values must be strings' unless data.all? { |k, v| k.is_a?(String) && v.is_a?(String) }

    halt 500, 'Failed to write file' unless write_key_values("#{@path}.info", data)

    reset_file_info_cache
    content_type :json
    json_ok(message: 'File updated successfully')
rescue JSON::ParserError
    halt 400, 'Invalid JSON in request body'
end