get '/view' do
    protected!
    @copy = $env.default_copy
    @key = []
    @file_tree = get_file_tree(@key)
    @all_dirs = collect_all_dirs(get_file_tree)
    @is_jailed = false
    erb :home, locals: {
        copy: @copy,
        file_tree: @file_tree,
        key: @key,
        is_jailed: @is_jailed,
        all_dirs: @all_dirs,
        read_only: false,
    }
end

get '/view/*' do
    file_path = URI.decode_www_form_component(params['splat'][0])
    key = file_path.split('/')
    initial_dir = key[0]
    is_public = initial_dir == 'public'

    protected! unless is_public

    @copy = $env.default_copy
    @key = key
    @all_dirs = collect_all_dirs(get_file_tree)
    @is_jailed = is_public # public visitors shouldn't browse above /public
    @file_tree = get_file_tree(@key)
    erb :home, locals: {
        copy: @copy,
        file_tree: @file_tree,
        key: @key,
        is_jailed: @is_jailed,
        all_dirs: @all_dirs,
        read_only: !is_logged_in?,
    }
end