class Util::Image
  class << self
    def remove_exif(path)
      system 'exiv2', 'rm', path
    end
  end
end
