module Cms::Model::Rel::Bracket
  extend ActiveSupport::Concern

  included do
    has_many :brackets, class_name: 'Cms::Bracket', dependent: :destroy, as: :owner
    after_save :save_brackets
  end

  def bracket_names
    names = body_with_bracket.to_s.scan(/\[\[(\w+)\/([^\]]+)\]\]/)
    names.map { |n1, n2| "#{n1}/#{n2}" }.uniq
  end

  private

  def body_with_bracket
    text_columns = self.class.columns.select { |c| c.type == :text || c.type == :string }
    text_columns.map { |c| send(c.name) }.join
  end

  def save_brackets
    _site_id = respond_to?(:site_id) ? site_id : respond_to?(:content) && content ? content.site_id : nil
    _concept_id = respond_to?(:concept_id) ? concept_id : nil
    return unless _site_id

    brackets.destroy_all
    bracket_names.each do |name|
      brackets.create(site_id: _site_id, concept_id: _concept_id, name: name)
    end
  end
end
