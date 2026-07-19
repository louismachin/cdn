get '/view' do
    protected!
    @copy = $env.default_copy
    @key = []
    @file_tree = get_file_tree(@key)
    @all_dirs = collect_all_dirs_from_disk
    @is_jailed = false
    erb :home, locals: {
        copy: @copy,
        file_tree: @file_tree,
        key: @key,
        is_jailed: @is_jailed,
        all_dirs: @all_dirs,
    }
end

get '/view/*' do
    protected!
    @copy = $env.default_copy
    file_path = URI.decode_www_form_component(params['splat'][0])
    @key = file_path.split('/')
    @all_dirs = collect_all_dirs_from_disk
    @is_jailed = false
    @file_tree = get_file_tree(@key)
    erb :home, locals: {
        copy: @copy,
        file_tree: @file_tree,
        key: @key,
        is_jailed: @is_jailed,
        all_dirs: @all_dirs,
    }
end