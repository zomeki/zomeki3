class Util::Image::Mobile
  class << self
    def reduce_size(path, dst_width, dst_height, mobile)
      img = Magick::Image.read(path).first
      img.auto_orient!
      img.resize!(*Util::Image.reduced_size(img.columns, img.rows, dst_width, dst_height))

      case mobile
      when Jpmobile::Mobile::Docomo
        img.format = 'JPEG' if img.format == 'PNG'
      when Jpmobile::Mobile::Au
        img.format = 'PNG' if img.format == 'JPEG'
        img.format = 'GIF'
      when Jpmobile::Mobile::Softbank
        img.format = 'JPEG' if img.format == 'GIF'
      end

      img
    rescue => e
      warn_log e
      nil
    end
  end
end
