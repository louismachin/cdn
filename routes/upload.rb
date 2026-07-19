post '/upload_text/?*' do
    directory_path = params['splat'] ? URI.decode_www_form_component(params['splat'][0]) : ''
    initial_dir = directory_path.split('/')[0] if !directory_path.empty?
    is_public = initial_dir == 'public'
    protected! unless is_public

    unless params['filename']
        halt 400, {
            'success' => false,
            'error' => 'Missing required fields',
            'debug_params' => params.to_s,
            'debug_query' => request.query_string,
            'debug_has_filename' => params.key?('filename').to_s,
        }.to_json
    end

    filename = params['filename']
    content = request.body.read

    # Build the full path: directory from splat + actual filename
    if directory_path.empty?
        full_path = File.join('data', filename)
    else
        full_path = File.join('data', directory_path, filename)
    end

    # Ensure the directory exists
    directory = File.dirname(full_path)
    FileUtils.mkdir_p(directory) unless Dir.exist?(directory)

    # Save the file
    File.open(full_path, 'wb') { |f| f.write(content) }

    clear_file_tree_cache
    content_type 'application/json'
    { :success => true }.to_json
end

post '/upload/?*' do
    directory_path = params['splat'] ? URI.decode_www_form_component(params['splat'][0]) : ''
    initial_dir = directory_path.split('/')[0] if !directory_path.empty?
    is_public = initial_dir == 'public'
    protected! unless is_public

    unless params[:file] && params[:file][:tempfile]
        halt 400, {
            'success' => false,
            'error' => 'Missing required fields',
            'debug' => 'POST /upload/?*',
        }.to_json
    end

    # Get the uploaded file
    uploaded_file = params[:file][:tempfile]
    filename = params[:file][:filename]

    # Build the full path: directory from splat + actual filename
    if directory_path.empty?
        full_path = File.join('data', filename)
    else
        full_path = File.join('data', directory_path, filename)
    end

    # Ensure the directory exists
    directory = File.dirname(full_path)
    FileUtils.mkdir_p(directory) unless Dir.exist?(directory)

    # Save the file
    File.open(full_path, 'wb') { |f| f.write(uploaded_file.read) }

    clear_file_tree_cache
    content_type 'application/json'
    { :success => true }.to_json
end

post '/new_folder/?*' do
    directory_path = params['splat'] ? URI.decode_www_form_component(params['splat'][0]) : ''
    initial_dir = directory_path.split('/')[0] if !directory_path.empty?
    is_public = initial_dir == 'public'
    protected! unless is_public

    unless params['name'] && !params['name'].strip.empty?
        halt 400, {
            'success' => false,
            'error' => 'Missing required fields',
        }.to_json
    end

    folder_name = params['name'].strip

    # Guard against path traversal / nested paths sneaking in via the name field
    if folder_name.include?('/') || folder_name.include?('\\') || folder_name == '.' || folder_name == '..'
        halt 400, {
            'success' => false,
            'error' => 'Invalid folder name',
        }.to_json
    end

    full_path = directory_path.empty? ? File.join('data', folder_name) : File.join('data', directory_path, folder_name)

    if Dir.exist?(full_path)
        halt 400, {
            'success' => false,
            'error' => 'Folder already exists',
        }.to_json
    end

    FileUtils.mkdir_p(full_path)

    clear_file_tree_cache
    content_type 'application/json'
    { :success => true }.to_json
end