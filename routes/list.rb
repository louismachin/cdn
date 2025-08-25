get '/list/*' do
    file_path = URI.decode_www_form_component(params['splat'][0])
    full_path = File.join('data', file_path)
    initial_dir = file_path.split('/')[0]
    is_public = initial_dir == 'public'

    protected! unless is_public

    is_success, files = false, []

    if File.directory?(full_path)
        is_success = true
        search_str = APP_ROOT + '/' + full_path + '/'
        files = Dir[search_str + '*']
        size = files
            .select { |f| File.file?(f) }
            .sum { |f| File.size(f) }
        files = files
            .map { |path| File.directory?(path) ? path + '/' : path }
            .map { |path| path.gsub(search_str, '') }
    end

    content_type 'application/json'
    { success: is_success, size: size, files: files }.to_json
end