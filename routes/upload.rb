get '/upload' do
    protected!
    @copy = $env.default_copy
    @key = params[:d] ? params[:d].split(DIR_DELIMITER) : []
    erb :upload, locals: { copy: @copy, key: @key, }
end

post '/upload' do
    protected!
    unless params[:file] && params[:file][:tempfile]
        halt 400, { 'success' => false, 'error' => 'Missing required fields' }.to_json
    end
    # Get the uploaded file
    uploaded_file = params[:file][:tempfile]
    filename = params[:file][:filename]
    # Create the full path where the file will be saved
    path_arr = [filename]
    path_arr = params[:d].split(DIR_DELIMITER) + path_arr if params[:d]
    file_path = File.join('data', *path_arr)
    # Save the file
    File.open(file_path, 'wb') { |f| f.write(uploaded_file.read) }
    clear_file_tree_cache
    { 'success' => true }.to_json
end