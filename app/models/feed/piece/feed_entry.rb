class Feed::Piece::FeedEntry < Cms::Piece

  default_scope { where(model: 'Feed::FeedEntry') }

  after_initialize :set_default_settings

  validate :validate_settings

  def validate_settings
    if (lc = in_settings['docs_number']).present?
      errors.add(:base, "#{self.class.human_attribute_name :docs_number} #{errors.generate_message(:base, :not_a_number)}") unless lc =~ /^[0-9]+$/
    end
  end

  def docs_number
    (setting_value(:docs_number).presence || 1000).to_i
  end

  def doc_style
    setting_value(:doc_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  private

  def set_default_settings
    settings = self.in_settings

    settings[:doc_style] = '@title_link@(@publish_date@)' if setting_value(:doc_style).nil?
    settings[:date_style] = '%Y年%m月%d日 %H時%M分' if setting_value(:date_style).nil?

    self.in_settings = settings
  end
  
end