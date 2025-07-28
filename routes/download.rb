old_download_file = proc do
    protected!
    file_path = params['splat'][0]
    full_path = File.join('data', file_path)
    if File.exist?(full_path)
        send_file full_path
    else
        halt 404, "File not found"
    end
end

download_file = proc do
    protected!

    file_path = params['splat'][0]
    full_path = File.join('data', file_path)

    unless File.exist?(full_path)
        halt 404, "File or directory not found"
    end

    if File.file?(full_path)
        send_file full_path
    elsif File.directory?(full_path)
        archive_name = "#{File.basename(file_path)}_#{Time.now.to_i}.tar.gz"
        archive_path = File.join('/tmp', archive_name)

        puts "Creating archive: #{archive_path}"
        system("tar -czf #{archive_path} -C #{File.dirname(full_path)} #{File.basename(full_path)}")

        content_type 'application/gzip'
        attachment "#{File.basename(file_path)}.tar.gz"

        puts "Sending file: #{archive_path}"
        send_file archive_path
    else
        halt 400, "Invalid file type"
    end
end

get '/download/*', &download_file
get '/dl/*', &download_file