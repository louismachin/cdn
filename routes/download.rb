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
        basename = File.basename(file_path)
        dirname = File.dirname(full_path)

        archive_name = "#{basename}_#{Time.now.to_i}.tar.gz"
        archive_path = File.join('/tmp', archive_name)

        system("tar -czf #{archive_path} -C #{dirname} #{basename}")

        content_type 'application/gzip'
        attachment "#{File.basename(file_path)}.tar.gz"

        send_file archive_path
    else
        halt 400, "Invalid file type"
    end
end

get '/download/*', &download_file
get '/dl/*', &download_file