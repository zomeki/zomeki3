class Sys::Lib::File::NoUploadedFile
  attr_accessor :path, :mime_type, :size, :filename

  def initialize(options = {})
    if options.key?(:path)
      @path = options[:path]
      @mime_type = options[:mime_type] || Util::File.mime_type(path)
    elsif options.key?(:data)
      @temp = Tempfile.new
      @temp.binmode
      @temp.write(options[:data])
      @path = @temp.path
      @mime_type = options[:mime_type] || Util::File.mime_type(path)
    else
      raise "unexpected option"
    end

    @filename = options[:filename]
    @size = ::File.size(@path)
  end

  def read
    ::File.binread(@path)
  end

  def content_type
    @mime_type
  end

  def original_filename
    @filename
  end
end
