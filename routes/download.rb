download_file = proc do
    file_path = URI.decode_www_form_component(params['splat'][0])
    full_path = File.join('data', file_path)
    initial_dir = file_path.split('/')[0]
    is_public = initial_dir == 'public'

    protected! unless is_public
    
    unless File.exist?(full_path)
        halt 404, "File or directory not found"
    end

    if File.file?(full_path)
        send_file full_path
    elsif File.directory?(full_path)
        protected! # don't allow public directory downloads

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

def heic_preview_path(original_path)
    original_path.sub(/\.heic\z/i, '.preview.jpg')
end

def ensure_heic_preview(original_path)
    preview_path = heic_preview_path(original_path)
    return preview_path if File.exist?(preview_path)
    success = system('heif-convert', original_path, preview_path)
    return nil unless success && File.exist?(preview_path)
    preview_path
end

def pdf_preview_path(original_path)
    original_path.sub(/\.pdf\z/i, '.preview')
end

def ensure_pdf_preview(original_path)
    # pdftoppm appends '-1.jpg' itself (page 1), so we pass a prefix
    prefix = pdf_preview_path(original_path)
    final_path = "#{prefix}-1.jpg"
    return final_path if File.exist?(final_path)

    success = system('pdftoppm', '-jpeg', '-f', '1', '-l', '1', '-scale-to', '600', original_path, prefix)
    return nil unless success && File.exist?(final_path)
    final_path
end

get '/preview/?*' do
    path = params['splat'] ? URI.decode_www_form_component(params['splat'][0]) : ''
    full_path = File.join(APP_ROOT, 'data', path)
    halt 404 unless File.exist?(full_path)

    preview =
        if full_path.downcase.end_with?('.heic')
            ensure_heic_preview(full_path)
        elsif full_path.downcase.end_with?('.pdf')
            ensure_pdf_preview(full_path)
        else
            full_path
        end

    halt 500, 'Preview conversion failed' unless preview
    send_file preview
end