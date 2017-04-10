class Sys::Storage::Uploader
  def initialize(current)
    @current = current
  end

  def upload_files(files, options = {})
    results = []
    zip_results = []
    files.each do |file|
      if options[:unzip] && file.original_filename =~ /^.+\.zip$/
        res = unzip_file(file, options)
        zip_results << { name: file.original_filename, results: res }
      else
        results += upload_file(file, options)
      end
    end
    return results, zip_results
  end

  private

  def upload_file(file, options)
    item = Sys::Storage::Entry.from_path(::File.join(@current.path, file.original_filename))
    item.entry_type = :file
    item.body = file.read
    item.allow_overwrite = options[:overwrite]
    if item.save
      [{ name: item.name, msg: 'アップロード完了', status: 'OK' }]
    else
      item.errors.full_messages.map do |msg|
        { name: item.name, msg: msg, status: 'NG' }
      end
    end
  end

  def unzip_file(file, options)
    res = []
    require 'zip'
    Zip::InputStream.open(file.tempfile, 0) do |input|
      while (entry = input.get_next_entry)
        name = entry.name.to_utf8

        item = Sys::Storage::Entry.from_path(::File.join(@current.path, name))
        if entry.name_is_directory?
          item.entry_type = :directory
        else
          item.entry_type = :file
          item.body = entry.get_input_stream { |stream| stream.read }
        end
        item.allow_overwrite = options[:overwrite]

        if item.save
          res << { name: name, msg: 'アップロード完了', status: 'OK' }
        else
          item.errors.full_messages.each do |msg|
            res << { name: name, msg: msg, status: 'NG' }
          end
        end
      end
    end
    res
  rescue => e
    error_log e
    [{ name: file.original_filename, msg: "ZIPファイルの解凍に失敗しました。(#{e})", status: 'NG' }]
  end
end
