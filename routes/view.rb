get '/view/?*' do
    key = clean_segments(params['splat']&.first)
    halt 400, 'Invalid path' unless key
    protected! unless key.first == 'public'

    logged_in = is_logged_in?
    erb :home, locals: {
        copy:      $env.default_copy,
        file_tree: get_file_tree(key),
        key:       key,
        is_jailed: !logged_in,
        all_dirs:  logged_in ? collect_all_dirs(get_file_tree) : [],
        read_only: !logged_in,
    }
end