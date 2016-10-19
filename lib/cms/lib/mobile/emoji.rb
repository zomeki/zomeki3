class Cms::Lib::Mobile::Emoji
  @@map = nil
  
  def self.convert(name, career)
    return '' unless map.has_key?(name)
    
    case career
    when Jpmobile::Mobile::Docomo
      # for docomo
      return map[name][1]
    when Jpmobile::Mobile::Au
      # for au
      return '&#x' + map[name][3] + ';';
    when Jpmobile::Mobile::Softbank
      # for SoftBank
      code = '1B24' + map[name][4] +  '0F';
      return [code].pack('H10');
    when Jpmobile::Mobile::Willcom
      # for Willcom
      return map[name][1]
    else
      # for PC
      return map[name][1]
    end
  end
  
  def self.map
    return @@map if @map
    return @@map = I18n.t('emoji').with_indifferent_access
  end
end
