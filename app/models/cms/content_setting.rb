class Cms::ContentSetting < ApplicationRecord
  include Sys::Model::Base
  
  @@configs = {}
  attr_accessor :form_type, :options
  
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Cms::Content'

  validates :content_id, :name, presence: true

  after_initialize :set_defaults_from_config

  def self.set_config(id, params = {})
    @@configs[self] ||= []
    @@configs[self] << params.merge(:id => id)
  end
  
  def self.configs(content)
    configs = []
    @@configs[self].each {|c| configs << config(content, c[:id])} if @@configs[self]
    configs
  end
  
  def self.config(content, name)
    self.where(content_id: content.id, name: name.to_s).first_or_initialize
  end

  def self.all_configs
    @@configs[self] || []
  end
  
  def editable?
    content.editable?
  end
  
  def config
    return @config if @config
    @@configs[self.class].each {|c| return @config = c if c[:id].to_s == name.to_s} if @@configs[self.class]
    nil
  end
  
  def config_name
    config ? config[:name] : nil
  end
  
  def config_options
    return config[:options].call if config[:options].is_a?(Proc)
    config[:options] ? config[:options].collect {|e| [e[0], e[1].to_s] } : nil
  end
  
  def upper_text
    config[:upper_text] ? config[:upper_text] : nil
  end
  
  def lower_text
    config[:lower_text] ? config[:lower_text] : nil
  end

  def form_type
    config[:form_type] || (config[:options] ? :select : :string)
  end

  def menu
    config[:menu]
  end

  def default_value
    config[:default_value]
  end

  def default_extra_values
    config[:default_extra_values]
  end

  def value_name
    opts = if config[:options].is_a?(Proc)
             config[:options].call
           else
             config[:options]
           end
    opts = opts.call(content) if opts.is_a?(Proc)

    case form_type
    when :select, :radio_buttons
      opts.detect { |o| o.last.to_s == value.to_s }.try(:first).to_s
    when :check_boxes
      (value || []).map { |v| opts.detect { |o| o.last.to_s == v.to_s }.try(:first) }.compact.join(', ')
    when :multiple_select
      config_options.where(id: (value || [])).map(&:name).join(', ')
    else
      value.presence
    end
  end

  def value=(v)
    case form_type
    when :check_boxes, :multiple_select
      super(YAML.dump(v ? v.reject(&:blank?) : '[]'))
    else
      super
    end
  end

  def value
    case form_type
    when :check_boxes, :multiple_select
      v = super
      v.present? ? YAML.load(v) : nil
    else
      super
    end
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

  def set_defaults_from_config
    return unless config

    if value.nil?
      self.value = config[:default_value] if config[:default_value]
    end
    if extra_values.nil?
      self.extra_values = config[:default_extra_values] if config[:default_extra_values]
    end
  end
end
