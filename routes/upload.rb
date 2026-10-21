post '/upload_text/?*' do
    name = safe_name!(params['filename'], 'Missing or invalid filename')
    FileUtils.mkdir_p(@dir)
    File.binwrite(File.join(@dir, name), request.body.read)
    clear_file_tree_cache
    json_ok
end

post '/upload/?*' do
    file = params['file']
    json_fail!(400, 'Missing file') unless file.is_a?(Hash) && file[:tempfile]
    name = safe_name!(file[:filename])
    FileUtils.mkdir_p(@dir)
    FileUtils.cp(file[:tempfile].path, File.join(@dir, name))
    clear_file_tree_cache
    json_ok
end

post '/new_folder/?*' do
    name = safe_name!(params['name'], 'Invalid folder name')
    path = File.join(@dir, name)
    json_fail!(409, 'Folder already exists') if File.exist?(path)
    FileUtils.mkdir_p(path)
    clear_file_tree_cache
    json_ok
end