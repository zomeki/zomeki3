class Util::File
  class << self
    def put(path, options ={})
      if options[:mkdir] == true
        dir = ::File.dirname(path)
        FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
      end
      if options[:data]
        begin
          f = File.open(path, "wb")
          begin
            f.flock(File::LOCK_EX) if options[:use_lock] != false
            f.write(options[:data])
            f.flock(File::LOCK_UN) if options[:use_lock] != false
          ensure
            f.close
          end
        end
      elsif options[:src]
        return false unless FileTest.exist?(options[:src])
        FileUtils.cp options[:src], path
      end
      return true
    end

    def file_type(path)
      return unless `file -v`
      require 'open3'
      Open3.capture3('file', path)[0]
    end

    def mime_type(path)
      return unless ::File.exist?(path)
      require 'open3'
      Open3.capture3('file', '-b', '--mime-type', path).first.strip
    end

    def remove_exif(path)
      return unless ::File.exist?(path)
      system 'exiv2', 'rm', path
    end

    def sanitize_filename(name)
      name.gsub(/[\x00-\x1F\/\\:\*\?\"<>\|]/u, '_')
    end
  end
end
