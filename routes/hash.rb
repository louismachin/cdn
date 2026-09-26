get '/hash/*' do
    file_path = URI.decode_www_form_component(params['splat'][0])
    full_path = File.join('data', file_path)
    initial_dir = file_path.split('/')[0]
    is_public = initial_dir == 'public'

    protected! unless is_public
    
    unless File.exist?(full_path)
        halt 404, "File or directory not found"
    end

    content_type :json
    if File.file?(full_path)
        stat = File.stat(full_path)
        {
            path:        full_path,
            name:        File.basename(full_path),
            size:        stat.size,
            mime_type:   Rack::Mime.mime_type(File.extname(full_path), 'application/octet-stream'),
            modified_at: stat.mtime.utc.iso8601,
            sha256:      file_sha256(full_path)
        }.to_json
    else
        { error: 'Not a file.' }.to_json
    end
end