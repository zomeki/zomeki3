module Cms::Model::Rel::Bracketee
  extend ActiveSupport::Concern

  def bracketees
    Cms::Bracket.where(name: bracket_name)
  end

  private

  def bracket_name
    return nil if name.blank?
    "#{Cms::Lib::Bracket.bracket_type(self.class)}/#{name}"
  end
end
