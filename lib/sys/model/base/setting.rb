module Sys::Model::Base::Setting
  extend ActiveSupport::Concern

  included do
    class_attribute :configs
    self.configs = {}

    after_initialize :set_defaults
  end

  def config
    self.configs[name.to_sym] || {}
  end

  def config_name
    config[:name]
  end

  def config_options
    config[:options]
  end

  def style
    config[:style]
  end

  def upper_text
    config[:upper_text]
  end

  def lower_text
    config[:lower_text]
  end

  def default_value
    config[:default_value]
  end

  def value_name
    if config[:options]
      config[:options].rassoc(value.to_s).try(:first)
    else
      value
    end
  end
  
  def form_type
    config[:form_type]
  end

  def extra_values=(ev)
    self.extra_value = YAML.dump(ev) if ev.is_a?(Hash)
    return ev
  end

  def extra_values
    ev_string = self.extra_value
    ev = ev_string.kind_of?(String) ? YAML.load(ev_string) : {}.with_indifferent_access
    ev = {}.with_indifferent_access unless ev.kind_of?(Hash)
    ev = ev.with_indifferent_access unless ev.kind_of?(ActiveSupport::HashWithIndifferentAccess)
    if block_given?
      yield ev
      self.extra_values = ev
    end
    return ev
  end

  private

  def set_defaults
    self.value ||= config[:default_value] if config[:default_value]
    self.extra_values ||= config[:default_extra_values] if config[:default_extra_values]
  end

  class_methods do
    def set_config(id, params = {})
      params[:id] ||= id
      params[:name] ||= nil
      params[:form_type] ||= params[:options] ? :select : :string
      params[:default_value] ||= nil
      params[:default_extra_values] ||= nil
      params[:options] ||= nil
      params[:style] ||= nil
      params[:upper_text] ||= nil
      params[:lower_text] ||= nil
      self.configs[id.to_sym] = params
    end
  end
end
