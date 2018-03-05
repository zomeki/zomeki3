class Organization::Piece::AllGroup < Cms::Piece
  default_scope { where(model: 'Organization::AllGroup') }

  belongs_to :content, class_name: 'Organization::Content::Group'

  after_initialize :set_default_settings

  def list_style
    setting_value(:list_style).to_s
  end

  private

  def set_default_settings
    settings = self.in_settings

    settings['list_style'] = '@name_link@' if setting_value(:list_style).nil?

    self.in_settings = settings
  end
end
