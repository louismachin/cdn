get '/mimetype/*' do
    content_type :json
    type =
    if    File.file?(@path)      then get_file_mimetype(@path)
    elsif File.directory?(@path) then 'directory'
    else  halt 400, { error: 'Invalid file type' }.to_json
    end
    { type: type }.to_json
end