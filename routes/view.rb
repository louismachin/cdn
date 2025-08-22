get '/view' do
    protected!
    @copy = $env.default_copy
    @key = []
    @file_tree = get_file_tree(@key)
    erb :home, locals: {
        copy: @copy,
        file_tree: @file_tree,
        key: @key,
    }
end

get '/view/*' do
    protected!
    @copy = $env.default_copy
    file_path = URI.decode_www_form_component(params['splat'][0])
    @key = file_path.split('/')
    @file_tree = get_file_tree(@key)
    erb :home, locals: {
        copy: @copy,
        file_tree: @file_tree,
        key: @key,
    }
end