module Cms::Model::Rel::Bracketee
  extend ActiveSupport::Concern

  def bracket_name
    return nil if name.blank?
    "#{Cms::Lib::Bracket.bracket_type(self.class)}/#{name}"
  end

  def bracketees
    bracketees_with_name(bracket_name)
  end

  def bracketees_with_name(name)
    Cms::Bracket.where(site_id: site_id, name: name)
  end
end
