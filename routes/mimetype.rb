get '/mimetype/*' do
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
        { type: get_file_mimetype(full_path) }.to_json
    elsif File.directory?(full_path)
        content_type 'application/json'
        { type: 'directory' }.to_json
    else
        halt 400, "Invalid file type"
    end
end