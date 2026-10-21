
download_file = proc do
    if File.file?(@path)
        send_file @path
    elsif File.directory?(@path)
        protected! # no public directory downloads

        name = @segments.last || 'data'
        dir, base = File.dirname(@path), File.basename(@path)

        content_type 'application/gzip'
        attachment "#{name}.tar.gz"
        stream do |out|
            IO.popen(['tar', '-czf', '-', '-C', dir, base]) do |io|
                out << chunk while (chunk = io.read(64 * 1024))
            end
        end
    else
        halt 400, 'Invalid file type'
    end
end

get '/download/*', &download_file
get '/dl/*',       &download_file