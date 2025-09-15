def load_key_values(path)
    return nil unless File.file?(path)
    lines = File.readlines(path).map(&:chomp)
    puts "load_key_values\tpath=#{path}"
    puts "load_key_values\tlines=#{lines}"
    data = {}
    lines.each do |line|
        key, value = line.split('=', 2)
        data[key] = value if key && key.size && value
    end
    return data
rescue => e
    puts "Error reading file: #{e.message}"
    return {}
end

def write_key_values(path, hash)
    puts "Opening file for writing: #{path}"
    File.open(path, 'w') do |file|
        hash.each do |key, value|
            line = "#{key}=#{value}"
            puts "Writing line: #{line}"
            file.puts line
        end
    end
    puts "File write completed successfully"
    return true
rescue => e
    puts "Error writing file: #{e.message}"
    puts "Error class: #{e.class}"
    puts "Backtrace: #{e.backtrace.join("\n")}"
    return false
end