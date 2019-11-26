class Cms::Piece::BreadCrumb < Cms::Piece
  default_scope { where(model: 'Cms::BreadCrumb') }

  def top_label
    setting_value(:top_label).to_s
  end

  def top_link_uri
    setting_value(:top_link_uri).to_s
  end
end
