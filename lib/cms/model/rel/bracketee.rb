module Cms::Model::Rel::Bracketee
  extend ActiveSupport::Concern

  def bracket_name
    return nil if name.blank?
    "#{Cms::Lib::Bracket.bracket_type(self)}/#{name}"
  end

  def bracketees
    bracketees_with_name(bracket_name)
  end

  def bracketees_with_name(name)
    Cms::Bracket.where(site_id: site_id).ci_match(name: name)
  end

  def changed_bracket_names
    type = Cms::Lib::Bracket.bracket_type(self)
    names = [name, name_was].select(&:present?).uniq
    names.map { |name| "#{type}/#{name}" }
  end
end
