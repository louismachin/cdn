PREVIEW_CACHE_ROOT = File.join(APP_ROOT, 'cache', 'previews')
FileUtils.mkdir_p(PREVIEW_CACHE_ROOT)

helpers do
    def preview_cache_prefix(original)
        key = Digest::SHA256.hexdigest("#{original}:#{File.mtime(original).to_i}")
        File.join(PREVIEW_CACHE_ROOT, key)
    end

    def ensure_heic_preview(original)
        out = "#{preview_cache_prefix(original)}.jpg"
        return out if File.exist?(out)
        system('heif-convert', original, out, out: File::NULL, err: File::NULL)
        out if File.exist?(out)
    end

    def ensure_pdf_preview(original)
        prefix = preview_cache_prefix(original)
        out = "#{prefix}.jpg"
        return out if File.exist?(out)
        system('pdftoppm',
            '-jpeg', '-singlefile', '-f', '1', '-l', '1',
            '-scale-to', '600', original, prefix,
            err: File::NULL
        )
        out if File.exist?(out)
    end
end

get '/preview/*' do
    halt 404 unless File.file?(@path)

    preview = case File.extname(@path).downcase
    when '.heic' then ensure_heic_preview(@path)
    when '.pdf'  then ensure_pdf_preview(@path)
    else @path
    end

    halt 500, 'Preview conversion failed' unless preview
    send_file preview
end