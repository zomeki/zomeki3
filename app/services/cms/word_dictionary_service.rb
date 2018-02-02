class Cms::WordDictionaryService < ApplicationService
  def initialize(dic)
    @words = []
    dic.to_s.split(/\r\n|\n/).each do |line|
      next if line !~ /,/
      data = line.split(/,/)
      @words << [data[0].strip, data[1].strip]
    end
  end

  def replace(text)
    return text if text.blank?
    @words.each { |src, dst| text = text.gsub(src, dst) }
    text
  end
end
