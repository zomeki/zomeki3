class Cms::WordDictionaryService < ApplicationService
  def initialize(dic)
    @words = []
    dic.to_s.split(/\r\n|\n/).each do |line|
      next if line !~ /,/ && line !~ /###/
      if line =~ /###/
        data = line.split(/###/)
        is_regex = true
      else
        data = line.split(/,/)
        is_regex = false
      end
      @words << [data[0].strip, data[1].strip, is_regex]
    end
  end

  def replace(text)
    return text if text.blank?
    @words.each do |src, dst, is_regex|
      if is_regex
        text = text.gsub(/#{src}/, dst)
      else
        text = text.gsub(src) { dst }
      end
    end
    text
  end
  
  def check(text)
    return errors if text.blank?
    
    words = []
    @words.each do |src, dst, is_regex|
      if is_regex
        text.scan(/(#{src})/) do |m|
          words << "#{m[0]} → #{m[0].to_s.gsub(/#{src}/, dst)}"
        end
      else
        words << "#{src} → #{dst}" if text.include?(src)
      end
    end
    
    words.size == 0 ? nil : words
  end
end
