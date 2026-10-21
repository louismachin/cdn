post '/move/*' do
    dest = safe_segments!(params['destination'], 'Missing or invalid destination')
    protected! unless dest.first == 'public'
    to = data_path(*dest)
    json_fail!(409, 'A file already exists at the destination') if File.exist?(to)

    FileUtils.mkdir_p(File.dirname(to))
    FileUtils.mv(@path, to)
    clear_file_tree_cache
    json_ok
end

get '/delete/*' do
    json_fail!(400, 'Refusing to delete a directory') if File.directory?(@path)

    ext   = File.extname(@path)
    stamp = Time.now.strftime('%Y%m%d_%H%M%S')
    trash = data_path('trash')
    FileUtils.mkdir_p(trash)
    FileUtils.mv(@path, File.join(trash, "#{File.basename(@path, ext)}_#{stamp}#{ext}"))
    clear_file_tree_cache
    json_ok
end

get '/rename/*' do
    target = params['target'].to_s.strip
    json_fail!(400, '?target= filename is required') if target.empty?
    json_fail!(400, 'Invalid filename') if target.match?(%r{[/\\]}) || %w[. ..].include?(target)

    dest = File.join(File.dirname(@path), target)
    json_fail!(409, 'File with that name already exists') if File.exist?(dest)

    FileUtils.mv(@path, dest)
    clear_file_tree_cache
    json_ok(old_name: File.basename(@path), new_name: target)
end