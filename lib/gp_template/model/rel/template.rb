module GpTemplate::Model::Rel::Template
  extend ActiveSupport::Concern

  attr_accessor :error_template_items

  included do
    serialize :template_values
    belongs_to :template, class_name: 'GpTemplate::Template'
    after_initialize :set_template_defaults
    before_validation :convert_template_values
    after_save :set_template_values_to_body
  end

  private

  def set_template_defaults
    self.template_values ||= {} if self.has_attribute?(:template_values)
  end

  def convert_template_values
    raw_value = self.read_attribute_before_type_cast(:template_values)
    self.template_values = raw_value.to_h.with_indifferent_access if raw_value.is_a?(ActionController::Parameters)
  end
  
  def validate_template_values
    return unless self.template
    self.error_template_items = []

    self.template.items.each do |item|
      next unless item.required?
      next if item.item_type == 'attachment_file_list'
      if self.template_values[item.name].to_s.blank?
        errors.add(item.title, "を入力してください。") 
        self.error_template_items << item.name
      end
    end
  end

  def set_template_values_to_body
    return unless self.template
    return unless self.respond_to?(:body) && self.respond_to?(:files)
    template_body = ApplicationController.helpers.template_body(self.template, self.template_values, self.files)
    self.update_column(:body, template_body)
  end

end
