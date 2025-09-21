get '/upload/?*' do
    file_path = params['splat'] ? URI.decode_www_form_component(params['splat'][0]) : ''
    initial_dir = file_path.split('/')[0] if !file_path.empty?
    is_public = initial_dir == 'public'
    protected! unless is_public
    
    @copy = $env.default_copy
    @key = file_path.empty? ? [] : file_path.split('/')
    erb :upload, locals: { copy: @copy, key: @key }
end

post '/upload/?*' do
    directory_path = params['splat'] ? URI.decode_www_form_component(params['splat'][0]) : ''
    initial_dir = directory_path.split('/')[0] if !directory_path.empty?
    is_public = initial_dir == 'public'
    protected! unless is_public

    unless params[:file] && params[:file][:tempfile]
        halt 400, { 'success' => false, 'error' => 'Missing required fields' }.to_json
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

post '/upload_text/?*' do
    directory_path = params['splat'] ? URI.decode_www_form_component(params['splat'][0]) : ''
    initial_dir = directory_path.split('/')[0] if !directory_path.empty?
    is_public = initial_dir == 'public'
    protected! unless is_public

    File.open('/tmp/sinatra_debug.log', 'a') do |f|
        f.puts "[#{Time.now}] Params: #{params.inspect}"
    end

    unless params['filename']
        halt 400, { 'success' => false, 'error' => 'Missing required fields' }.to_json
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