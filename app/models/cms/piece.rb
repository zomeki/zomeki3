class Cms::Piece < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Base::Piece
  include Cms::Model::Base::Page::Publisher
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Rel::Content
  include Sys::Model::Rel::ObjectRelation
  include Cms::Model::Rel::Bracket
  include Cms::Model::Rel::Bracketee
  include Cms::Model::Auth::Concept

  include StateText
  include Cms::Base::PublishQueue::Bracketee

  has_many :settings, -> { order(:sort_no) }, :foreign_key => :piece_id,
    :class_name => 'Cms::PieceSetting', :dependent => :destroy

  attr_accessor :setting_save_skip

  validates :state, :model, :name, :title, presence: true
  validates :name, uniqueness: { scope: :concept_id, if: %Q(!replace_page?) },
    format: { with: /\A[0-9a-zA-Z\-_]+\z/, if: "name.present?", message: :invalid_bracket_name }

  after_save :save_settings
  after_save :replace_new_piece

  scope :public_state, -> { where(state: 'public') }

  def owner_layouts
    Cms::Layout.where(id: bracketees.select(:owner_id).where(owner_type: 'Cms::Layout'))
               .order(:concept_id, :name)
  end

  def replace_new_piece
    if state == "public" && rep = replace_page
      rep.destroy
    end
    return true
  end

  def in_settings
    unless @in_settings
      values = {}
      settings.each do |st|
        if st.sort_no
          values[st.name] ||= {}
          values[st.name][st.sort_no] = st.value
        else
          values[st.name] = st.value
        end
      end
      @in_settings = values
    end
    @in_settings.with_indifferent_access
  end

  def in_settings=(values)
    @in_settings = values
  end

  def locale(name)
    model = self.class.to_s.underscore
    label = ''
    if model != 'cms/piece'
      label = I18n.t name, :scope => [:activerecord, :attributes, model]
      return label if label !~ /^translation missing:/
    end
    label = I18n.t name, :scope => [:activerecord, :attributes, 'cms/piece']
    return label =~ /^translation missing:/ ? name.to_s.humanize : label
  end

  def css_id
    name.gsub(/-/, '_').camelize(:lower)
  end

  def css_attributes
    attr = ''

    attr += ' id="' + css_id + '"' if css_id != ''

    _cls = 'piece'
    attr += ' class="' + _cls + '"' if _cls != ''

    attr
  end

  def new_setting(name = nil)
    Cms::PieceSetting.new({:piece_id => id, :name => name.to_s})
  end

  def setting_value(name)
    st = settings.detect{|st| st.name == name.to_s}
    st ? st.value : nil
  end

  def setting_extra_values(name)
    st = settings.detect{|st| st.name == name.to_s}
    st ? st.extra_values : {}.with_indifferent_access
  end

  def setting_extra_value(name, extra_name)
    setting_extra_values(name)[extra_name]
  end

  def duplicate(rel_type = nil)

    new_attributes = self.attributes
    new_attributes[:id] = nil
    new_attributes[:created_at] = nil
    new_attributes[:updated_at] = nil
    new_attributes[:recognized_at] = nil
    new_attributes[:published_at] = nil

    item = self.class.new(new_attributes)

    if rel_type == nil
      item.name  = nil
      item.title = item.title.gsub(/^(【複製】)*/, "【複製】")
    elsif rel_type == :replace
      item.state = "closed"
    end

    item.setting_save_skip = true
    return false unless item.save(:validate => false)

    # piece_settings
    settings.each do |setting|
      setting_attributes = setting.attributes
      setting_attributes[:id] = nil
      setting_attributes[:piece_id] = item.id
      setting_attributes[:created_at] = nil
      setting_attributes[:updated_at] = nil
      dupe_setting = Cms::PieceSetting.new(setting_attributes)
      dupe_setting.save(:validate => false)
    end

    Sys::ObjectRelation.create(source: item, related: self, relation_type: 'replace') if rel_type == :replace

    return item
  end

protected
  def save_settings
    return true if setting_save_skip

    in_settings.each do |name, value|
      name = name.to_s

      if !value.is_a?(Hash)
        st = settings.find_by(name: name) || new_setting(name)
        st.value   = value
        st.sort_no = nil
        st.save if st.changed?
        next
      end

      _settings = settings.where(name: name).to_a
      value.each_with_index do |data, idx|
        st = _settings[idx] || new_setting(name)
        st.sort_no = data[0]
        st.value   = data[1]
        st.save if st.changed?
      end
      (_settings.size - value.size).times do |i|
        idx = value.size + i - 1
        _settings[idx].destroy
        _settings.delete_at(idx)
      end
    end
    return true
  end
end
