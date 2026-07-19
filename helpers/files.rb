DIR_DELIMITER = ';;'

def disk_space
    file_path = APP_ROOT + '/data'
    output = `df -m #{file_path}`
    # df -m output:
    # Filesystem  1M-blocks  Used  Available  Use%  Mounted on
    lines = output.strip.split("\n")
    return { used: 0, free: 0 } if lines.size < 2

    fields = lines[1].split(/\s+/)
    used_mb = fields[2].to_i
    free_mb = fields[3].to_i

    { used: used_mb, free: free_mb }
rescue
    { used: 0, free: 0 }
end

space = disk_space
puts "Used: #{space[:used]}"
puts "Free: #{space[:free]}"

def array_to_nested_structure(files)
    root_files = files.select { |file| !file.include?('/') }
    root_files.reject! { |file| file.end_with?('.info') }

    nested_files = files.select { |file| file.include?('/') }
    nested_files.reject! { |file| file.end_with?('.info') }

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

# Walks the real filesystem and merges any directories with no files
# (which array_to_nested_structure can never see, since it only infers
# folders from file paths) into the tree built from files.
def merge_empty_dirs(tree, base_path)
    return tree unless Dir.exist?(base_path)

    Dir.entries(base_path).each do |entry|
        next if entry == '.' || entry == '..'
        full_path = File.join(base_path, entry)
        next unless File.directory?(full_path)

        existing_branch = tree.find { |b| b.is_a?(Hash) && b.keys[0] == entry }
        if existing_branch
            existing_branch[entry] = merge_empty_dirs(existing_branch[entry], full_path)
        else
            tree << { entry => merge_empty_dirs([], full_path) }
        end
    end

    tree
end

$cached_file_tree = nil

def clear_file_tree_cache
    $cached_file_tree = nil
end

def get_file_tree(key = nil)
    if $cached_file_tree && (!$cached_file_tree.expired?)
        tree = $cached_file_tree.data.clone
    else
        arr = Dir[APP_ROOT + '/data/**/*.*'].map { |dir| dir.gsub(APP_ROOT + '/data/', '') }
        tree = array_to_nested_structure(arr)
        tree = merge_empty_dirs(tree, APP_ROOT + '/data')
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

$cached_file_info = {}

def get_file_info(path)
    return $cached_file_info[path] if $cached_file_info.include?(path)
    info_path = path + '.info'
    if File.file?(info_path)
        info = load_key_values(info_path)
        puts "get_file_info\tinfo=#{info.inspect}"
    else
        info = {}
    end
    return info
end

def reset_file_info_cache
    $cached_file_info = {}
end

def collect_all_dirs(tree, prefix = [])
    dirs = []
    tree.each do |branch|
        next if branch.is_a?(String)
        dir_name = branch.keys[0]
        full_path = prefix + [dir_name]
        dirs << full_path
        dirs.concat(collect_all_dirs(branch[dir_name], full_path))
    end
    dirs
end

# Converts a byte count into a short human-readable string, e.g. 1536 -> "1.5 KB"
def human_file_size(bytes)
    return '0 B' if bytes.nil? || bytes <= 0

    units = ['B', 'KB', 'MB', 'GB', 'TB']
    size = bytes.to_f
    unit_index = 0

    while size >= 1024 && unit_index < units.length - 1
        size /= 1024
        unit_index += 1
    end

    if unit_index == 0
        "#{size.to_i} #{units[unit_index]}"
    else
        "#{format('%.1f', size)} #{units[unit_index]}"
    end
end

# Builds the on-disk path for a file given its path segments (e.g. ['public', 'photos', 'foo.jpg'])
def file_disk_path(segments)
    File.join(APP_ROOT, 'data', *segments)
end

# Returns a human-readable size label for a file given its path segments, or nil if it doesn't exist
def file_size_label(segments)
    path = file_disk_path(segments)
    return nil unless File.file?(path)
    human_file_size(File.size(path))
end