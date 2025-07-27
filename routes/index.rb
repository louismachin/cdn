get '/' do
    protected!
    @copy = $env.default_copy
    @key = params[:d] ? params[:d].split(DIR_DELIMITER) : []
    @file_tree = get_file_tree(@key)
    erb :home, locals: {
        copy: @copy,
        file_tree: @file_tree,
        key: @key,
    }
end