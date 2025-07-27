DIR_DELIMITER = ';;'

def array_to_nested_structure(files)
    root_files = files.select { |file| !file.include?('/') }
    nested_files = files.select { |file| file.include?('/') }
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

def get_file_tree(key = nil)
    arr = Dir[APP_ROOT + '/data/**/*.*']
        .map { |dir| dir.gsub(APP_ROOT + '/data/', '') }
    tree = array_to_nested_structure(arr)
    unless key.nil?
        key.each do |dir|
            branch = get_branch(tree, dir)
            return [] unless branch
            tree = branch
        end
    end
    return tree
end