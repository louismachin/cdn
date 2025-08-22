get '/list/*' do
    file_path = URI.decode_www_form_component(params['splat'][0])
    full_path = File.join('data', file_path)
    initial_dir = file_path.split('/')[0]
    is_public = initial_dir == 'public'

    protected! unless is_public

    if File.directory?(full_path)
        search_path = APP_ROOT + '/' + full_path + '/*'
        puts search_path
        files = Dir[search_path]
            .map { |dir| dir.gsub(APP_ROOT + '/data/', '') }
        { success: true, files: files }.to_json
    else
        { success: false, files: [] }.to_json
    end
end