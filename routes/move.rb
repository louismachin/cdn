get '/delete/*' do
    file_path = URI.decode_www_form_component(params['splat'][0])
    full_path = File.join('data', file_path)
    initial_dir = file_path.split('/')[0]
    protected!
   
    unless File.exist?(full_path)
        content_type 'application/json'
        status 404
        { :success => false, :error => 'File or directory not found', }.to_json
    end

    # Create trash directory if it doesn't exist
    trash_dir = File.join('data', 'trash')
    Dir.mkdir(trash_dir) unless Dir.exist?(trash_dir)

    # Create new file
    filename = File.basename(full_path)
    file_ext = File.extname(filename)
    file_base = File.basename(filename, file_ext)
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    trash_path = File.join(trash_dir, "#{file_base}_#{timestamp}#{file_ext}")

    begin
        FileUtils.mv(full_path, trash_path)
        clear_file_tree_cache
        content_type 'application/json'
        status 200
        { :success => true, }.to_json
    rescue => e
        content_type 'application/json'
        status 500
        { :success => false, :error => e.message, }.to_json
    end
end

get '/rename/*' do
    file_path = URI.decode_www_form_component(params['splat'][0])
    full_path = File.join('data', file_path)
    initial_dir = file_path.split('/')[0]
  
    protected!

    unless File.exist?(full_path)
        content_type 'application/json'
        status 404
        return { :success => false, :error => 'File or directory not found' }.to_json
    end
  
    new_filename = params['target']
    directory = File.dirname(full_path)
    new_full_path = File.join(directory, new_filename)

    unless new_filename && !new_filename.strip.empty?
        content_type 'application/json'
        status 400
        return { :success => false, :error => '?target= filename is required' }.to_json
    end

    if new_filename.include?('/') || new_filename.include?('\\') || new_filename.include?('..')
        content_type 'application/json'
        status 400
        return { :success => false, :error => 'Invalid filename' }.to_json
    end

    if File.exist?(new_full_path)
        content_type 'application/json'
        status 409
        return { :success => false, :error => 'File with that name already exists' }.to_json
    end
  
    begin
        FileUtils.mv(full_path, new_full_path)
        clear_file_tree_cache
        content_type 'application/json'
        status 200
        { :success => true, :old_name => File.basename(full_path), :new_name => new_filename }.to_json
    rescue => e
        content_type 'application/json'
        status 500
        { :success => false, :error => e.message }.to_json
    end
end