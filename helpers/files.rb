DIR_DELIMITER = ';;'

def array_to_nested_structure(files)
    root_files = files.select { |file| !file.include?('/') }
    root_files.reject! { |file| file.endswith('.info') }
    nested_files = files.select { |file| file.include?('/') }
    nested_files.reject! { |file| file.endswith('.info') }
    result = root_files.dup
    grouped = nested_files.group_by { |file| file.split('/')[0] }
    grouped.each do |dir, files_in_dir|
        remaining_paths = files_in_dir.map do |file|
            parts = file.split('/')
            parts[1..-1].join('/')
        end.reject(&:empty?)
        if remaining_paths.any? { |path| path.include?('/') }
            dir_contents = array_to_nested_structure(remaining_paths)
        else
            dir_contents = remaining_paths
        end
        result << { dir => dir_contents }
    end
    return result
end

def get_branch(tree, dir)
    for branch in tree do
        next if branch.is_a?(String)
        return branch[dir] if branch.keys[0] == dir
    end
    return []
end

$cached_file_tree = nil

def clear_file_tree_cache
    $cached_file_tree = nil
end

def get_file_tree(key = nil)
    if $cached_file_tree && (!$cached_file_tree.expired?)
        tree = $cached_file_tree.data.clone
    else
        arr = Dir[APP_ROOT + '/data/**/*.*']
            .map { |dir| dir.gsub(APP_ROOT + '/data/', '') }
        tree = array_to_nested_structure(arr)
        $cached_file_tree = Cache.new(Time.now, tree, 3600)
    end
    unless key.nil?
        key.each do |dir|
            branch = get_branch(tree, dir)
            return [] unless branch
            tree = branch
        end
    end
    return tree
end

$cached_file_mimetypes = {}

def get_file_mimetype(path)
    return $cached_file_mimetypes[path] if $cached_file_mimetypes.include?(path)
    command = ["file", "--brief", "--mime-type", path]
    mimetype = IO.popen(command, in: :close, err: :close).read.chomp
    $cached_file_mimetypes[path] = mimetype
    return mimetype
end