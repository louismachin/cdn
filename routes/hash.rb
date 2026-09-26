get '/hash/*' do
    requested = URI.decode_www_form_component(params['splat'][0].to_s)
    full_path = resolve_data_path(requested)
    relative  = full_path.delete_prefix(DATA_ROOT).delete_prefix('/')

    protected! unless relative.split('/').first == 'public'
    halt 404, 'File not found' unless File.exist?(full_path)
    halt 400, 'Not a file' unless File.file?(full_path)

    stat = File.stat(full_path)

    content_type :json
    {
        path:        relative,
        name:        File.basename(full_path),
        size:        stat.size,
        mime_type:   Rack::Mime.mime_type(File.extname(full_path), 'application/octet-stream'),
        modified_at: stat.mtime.utc.iso8601,
        sha256:      file_sha256(full_path)
    }.to_json
end