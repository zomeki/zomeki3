class Cms::Content < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Base::Content
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept

  has_many :settings, -> { order(:sort_no) },
    :foreign_key => :content_id, :class_name => 'Cms::ContentSetting', :dependent => :destroy
  has_many :pieces, :foreign_key => :content_id, :class_name => 'Cms::Piece',
    :dependent => :destroy
  has_many :nodes, :foreign_key => :content_id, :class_name => 'Cms::Node',
    :dependent => :destroy

  # conditional
  has_many :public_nodes, -> { public_state }, foreign_key: :content_id, class_name: 'Cms::Node'
  has_many :public_pieces, -> { public_state }, foreign_key: :content_id, class_name: 'Cms::Piece'

  validates :concept_id, :state, :model, :name, presence: true
  validates :code, presence: true,
                   uniqueness: { scope: [:site_id] },
                   format: { with: /\A[0-9a-zA-Z\-_]+\z/, if: "name.present?", message: :invalid_bracket_name }

  before_create :set_default_settings_from_configs
  after_save :save_settings

  def readable?
    Core.user.has_priv?(:read, item: concept)
  end

  def in_settings
    unless @in_settings
      values = {}
      settings.each do |st|
        if st.sort_no
          values[st.name] ||= {}
          values[st.name][st.sort_no] = value
        else
          values[st.name] = st.value
        end
      end
      @in_settings = values
    end
    @in_settings
  end

  def in_settings=(values)
    @in_settings = values
  end

  def locale(name)
    model = self.class.to_s.underscore
    label = ''
    if model != 'cms/content'
      label = I18n.t name, :scope => [:activerecord, :attributes, model]
      return label if label !~ /^translation missing:/
    end
    label = I18n.t name, :scope => [:activerecord, :attributes, 'cms/content']
    return label =~ /^translation missing:/ ? name.to_s.humanize : label
  end

  def states
    [['公開','public']]
  end

  def new_setting(name = nil)
    Cms::ContentSetting.new({:content_id => id, :name => name.to_s})
  end

  def setting_value(name, default = nil)
    st = settings.detect { |s| s.name == name.to_s }
    if st && st.value
      st.value
    else
      default || config(name)[:default_value]
    end
  end

  def setting_extra_values(name, default = nil)
    st = settings.detect { |s| s.name == name.to_s }
    if st && st.extra_values
      st.extra_values
    else
      default || config(name)[:default_extra_values] || {}.with_indifferent_access
    end
  end

  def setting_extra_value(name, extra_name)
    setting_extra_values(name)[extra_name]
  end

  def model_content_klass
    model.sub('::', '::Content::').constantize
  rescue NameError
    nil
  end

  def downcast
    klass = model_content_klass
    klass ? becomes(klass) : self
  end

  private

  def config(name)
    settings.klass.new(name: name).config || {}
  end

  def save_settings
    in_settings.each do |name, value|
      st = settings.where(name: name).first || new_setting(name)
      st.value = value
      st.save if st.changed?
    end
    return true
  end

  def set_default_settings_from_configs
    settings.klass.all_configs.each do |config|
      next if config[:default_value].blank?

      setting = settings.build(name: config[:id])
      setting.value = config[:default_value]
      setting.extra_values = config[:default_extra_values] if config[:default_extra_values]
    end
  end
end
