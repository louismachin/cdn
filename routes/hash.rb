get '/hash/*' do
    content_type :json
    halt 400, { error: 'Not a file' }.to_json unless File.file?(@path)

    stat = File.stat(@path)
    {
        path:        @segments.join('/'),
        name:        File.basename(@path),
        size:        stat.size,
        mime_type:   Rack::Mime.mime_type(File.extname(@path), 'application/octet-stream'),
        modified_at: stat.mtime.utc.iso8601,
        sha256:      file_sha256(@path)
    }.to_json
end