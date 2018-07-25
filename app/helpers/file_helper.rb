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

  def replace_file_path(html, base:)
    return html if html.blank?
    uri = Addressable::URI.join(base, "file_contents/").to_s
    html.gsub(%r{(["'])file_contents/([^"']+?)(["'])}, "\\1#{uri}\\2\\3")
  end

  def replace_file_path_for_link(link, base:)
    return link if link.blank?
    link.sub(/\Afile_contents\//, "#{base}file_contents/")
  end

  def file_mtime(path)
    File.mtime(path)
  rescue Errno::ENOENT
    nil
  end
end
