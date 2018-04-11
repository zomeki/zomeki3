module Cms::Model::Rel::Bracket
  extend ActiveSupport::Concern

  included do
    has_many :brackets, class_name: 'Cms::Bracket', dependent: :destroy, as: :owner
    after_save :save_brackets
  end

  def bracket_names
    text = self.class.columns.select { |c| c.type == :text || c.type == :string }
                             .map { |c| send(c.name) }.join

    text.to_s.scan(/\[\[(\w+)\/([^\]]+)\]\]/).map { |n1, n2| "#{n1}/#{n2}" }.uniq
  end

  def save_brackets
    brackets.destroy_all
    bracket_names.each do |name|
      brackets.create(site_id: site.id,
                      concept_id: respond_to?(:concept_id) ? concept_id : nil,
                      name: name)
    end
  end
end
