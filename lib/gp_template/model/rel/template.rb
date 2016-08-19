module GpTemplate::Model::Rel::Template
  extend ActiveSupport::Concern

  included do
    serialize :template_values
    belongs_to :template, :class_name => 'GpTemplate::Template'
    after_initialize :set_template_defaults
    before_validation :convert_template_values
    before_save :make_template_file_contents_path_relative
  end

  def set_template_defaults
    unless self.persisted?
      self.template_id ||= content.default_template.id if self.has_attribute?(:template_id) && content && content.default_template
    end
    self.template_values ||= {} if self.has_attribute?(:template_values)
  end

  private

  def convert_template_values
    raw_value = self.read_attribute_before_type_cast(:template_values)
    self.template_values = raw_value.to_h.with_indifferent_access if raw_value.is_a?(ActionController::Parameters)
  end

  def make_template_file_contents_path_relative
    return unless template

    template.items.each do |item|
      if item.item_type == 'rich_text'
        self.template_values[item.name] = self.template_values[item.name].to_s.gsub(%r|"[^"]*?/(file_contents/)|, '"\1')
      end
    end
  end
end
