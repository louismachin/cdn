FILE_ROUTES = %r{/(download|dl|preview|hash|list|info)/(.*)}
FILE_ACTIONS = %r{/(move|delete|rename)/(.*)}
FILE_CREATES = %r{/(upload_text|upload|new_folder)(?:/(.*))?}

helpers ERB::Util

helpers do
    def json_ok(**extra)
        { success: true, **extra }.to_json
    end

    def json_fail!(code, message)
        halt code, { success: false, error: message }.to_json
    end

    def data_path(*segments)
        File.join(APP_ROOT, 'data', *segments)
    end

    def clean_segments(path)
        # Returns path segments, or nil if the path tries to traverse
        segs = path.to_s.split('/').reject(&:empty?)
        segs unless segs.any? { |s| s == '.' || s == '..' }
    end

    def safe_segments!(path, message = 'Invalid path')
        segs = clean_segments(path)
        json_fail!(400, message) if segs.nil? || segs.empty?
        segs
    end
    
    def path_url(prefix, segments)
        # Builds "/prefix/a%20b/c.jpg" from ["a b", "c.jpg"]
        "/#{prefix}/" + segments.map { |s| ERB::Util.url_encode(s) }.join('/')
    end

    def safe_name!(name, message = 'Invalid filename')
        # A single path component: no slashes, no NULs, not . or ..
        name = name.to_s.strip
        json_fail!(400, message) if name.empty? || name.match?(%r{[/\\\0]}) || %w[. ..].include?(name)
        name
    end

    def copy
        @copy ||= $env.default_copy
    end
end

error SystemCallError do
    content_type :json
    status 500
    { success: false, error: env['sinatra.error'].message }.to_json
end

before FILE_ROUTES do
    @segments = clean_segments(params['captures'][1])
    halt 400, 'Invalid path' unless @segments
    protected! unless @segments.first == 'public'
    @path = data_path(*@segments)
    halt 404, 'File or directory not found' unless File.exist?(@path)
end

before FILE_ACTIONS do
    content_type :json
    @action, rel = params['captures']   # already URL-decoded by Sinatra
    @segments    = safe_segments!(rel)
    protected! unless @action == 'move' && @segments.first == 'public'
    @path = data_path(*@segments)
    json_fail!(404, 'File not found') unless File.exist?(@path)
end

before FILE_CREATES do
    content_type :json
    @segments = clean_segments(params['captures'][1])
    json_fail!(400, 'Invalid path') unless @segments
    protected! unless @segments.first == 'public'
    @dir = data_path(*@segments)
    json_fail!(400, 'Not a directory') if File.exist?(@dir) && !File.directory?(@dir)
end