def load_key_values(path)
    return nil unless File.file?(path)
    lines = File.readlines(path).map(&:chomp)
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
    File.open(path, 'w') do |file|
        hash.each do |key, value|
            file.puts "#{key}=#{value}"
        end
    end
    return true
rescue => e
    puts "Error writing file: #{e.message}"
    return false
end