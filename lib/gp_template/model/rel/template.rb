module GpTemplate::Model::Rel::Template
  extend ActiveSupport::Concern

  included do
    serialize :template_values
    belongs_to :template, class_name: 'GpTemplate::Template'
    after_initialize :set_template_defaults
    before_validation :convert_template_values
    before_save :set_template_values_to_body
  end

  private

  def set_template_defaults
    self.template_values ||= {} if self.has_attribute?(:template_values)
  end

  def convert_template_values
    raw_value = self.read_attribute_before_type_cast(:template_values)
    self.template_values = raw_value.to_h.with_indifferent_access if raw_value.is_a?(ActionController::Parameters)
  end
  
  def set_template_values_to_body
    return unless self.template
    return unless self.respond_to?(:body) && self.respond_to?(:files)
    template_body = ''
    template.items.each do |item|
      template_body += ApplicationController.helpers.template_item_value(item, template_values[item.name].to_s, self.files)
    end
    self.body = template_body
  end

end
