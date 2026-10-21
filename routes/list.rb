get '/list/*' do
    content_type :json
    halt 400, { success: false, error: 'Not a directory' }.to_json unless File.directory?(@path)

    entries = Dir.children(@path).reject { |name| name.start_with?('.') }.sort
    full    = entries.map { |name| File.join(@path, name) }

    {
        success: true,
        size:    full.select { |f| File.file?(f) }.sum { |f| File.size(f) },
        files:   entries.zip(full).map { |name, f| File.directory?(f) ? "#{name}/" : name }
    }.to_json
end