module GpTemplate::Model::Rel::Template
  extend ActiveSupport::Concern

  included do
    serialize :template_values
    belongs_to :template, :class_name => 'GpTemplate::Template'
    after_initialize :set_template_defaults
    before_validation :convert_template_values
  end

  private

  def set_template_defaults
    self.template_values ||= {} if self.has_attribute?(:template_values)
  end

  def convert_template_values
    raw_value = self.read_attribute_before_type_cast(:template_values)
    self.template_values = raw_value.to_h.with_indifferent_access if raw_value.is_a?(ActionController::Parameters)
  end
end
