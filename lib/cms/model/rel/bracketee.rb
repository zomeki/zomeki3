module Cms::Model::Rel::Bracketee
  extend ActiveSupport::Concern

  def bracket_name
    return if name.blank?
    "#{Cms::Bracket.bracket_type(self)}/#{name}"
  end

  def bracketees
    Cms::Bracket.where(site_id: site_id).ci_match(name: bracket_name)
  end

  def changed_bracket_names
    type = Cms::Bracket.bracket_type(self)
    [name, name_was].select(&:present?).uniq.map { |n| "#{type}/#{n}" }
  end
end
