module FileHelper
  def file_icon_class(name)
    if ext = File::extname(name).downcase[1..5]
      conv = {
        'xlsx' => 'xls',
      }
      ext = conv[ext] if conv[ext]
      ext = ext.gsub(/[^0-9a-z]/, '')
      'iconFile icon' + ext.gsub(/\b\w/) {|word| word.upcase}
    else
      'iconFile'
    end
  end

  def human_image_size(width, height)
    "( #{width}x#{height} )"
  end

  def thumbnail_style(src_width, src_height, dst_width, dst_height)
    width, height = Util::Image.reduced_size(src_width, src_height, dst_width, dst_height)
    "width: #{width}px; height: #{height}px;"
  end
end
