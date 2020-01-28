class GpArticle::Doc < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Editor
  include Sys::Model::Rel::EditableGroup
  include Sys::Model::Rel::File
  include Sys::Model::Rel::Task
  include Cms::Model::Base::Page
  include Cms::Model::Base::Qrcode
  include Cms::Model::Rel::Content
  include Cms::Model::Rel::Inquiry
  include Cms::Model::Rel::Map
  include Cms::Model::Rel::Bracket
  include Cms::Model::Rel::Link
  include Cms::Model::Rel::PublishUrl
  include Cms::Model::Rel::SearchText
  include Cms::Model::Rel::Importation
  include Cms::Model::Rel::Period

  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::Trash
  include Sys::Model::Auth::EditableGroup

  include GpArticle::Model::Rel::Category
  include GpArticle::Model::Rel::Tag
  include GpArticle::Model::Rel::RelatedDoc
  include Approval::Model::Rel::Approval
  include GpTemplate::Model::Rel::Template

  default_scope { where.not(state: 'archived') }

  column_attribute :href, default: ''
  column_attribute :title, default: ''
  column_attribute :mobile_title, default: ''
  column_attribute :subtitle, default: ''
  column_attribute :summary, default: ''
  column_attribute :body, default: '', html: true, fts: true
  column_attribute :mobile_body, default: '', html: true
  column_attribute :body_more, default: '', html: true
  column_attribute :terminal_pc_or_smart_phone, default: true
  column_attribute :terminal_mobile, default: true
  column_attribute :body_more_link_text, default: '続きを読む'
  column_attribute :filename_base, default: 'index'

  enum_ish :state, [:draft, :approvable, :approved, :prepared, :public, :closed, :trashed, :archived], predicate: true
  enum_ish :target, ['', '_self', '_blank', 'attached_file'], default: ''
  enum_ish :event_state, [:visible, :hidden], default: :hidden
  enum_ish :marker_state, [:visible, :hidden], default: :hidden
  enum_ish :navigation_state, [:enabled, :disabled], default: :disabled, predicate: true
  enum_ish :og_type, [:article]
  enum_ish :feature_1, [true, false], default: true
  enum_ish :feed_state, [:visible, :hidden]

  # Content
  belongs_to :content, class_name: 'GpArticle::Content::Doc', required: true

  # Page
  belongs_to :concept, foreign_key: :concept_id, class_name: 'Cms::Concept'
  belongs_to :layout, foreign_key: :layout_id, class_name: 'Cms::Layout'

  has_many :users_holds, as: :holdable, class_name: 'Sys::UsersHold', dependent: :delete_all
  has_many :operation_logs, -> { where(item_model: 'GpArticle::Doc') },
           foreign_key: :item_id, class_name: 'Sys::OperationLog'

  belongs_to :prev_edition, -> { where.not(state: 'trashed') }, class_name: self.name
  has_one :next_edition, -> { where.not(state: 'trashed') }, foreign_key: :prev_edition_id, class_name: self.name

  belongs_to :marker_icon_category, class_name: 'GpCategory::Category'

  has_many :categorizations, class_name: 'GpCategory::Categorization', as: :categorizable, dependent: :destroy
  has_many :categories, -> { where(GpCategory::Categorization.arel_table[:categorized_as].eq('GpArticle::Doc')) },
           class_name: 'GpCategory::Category', through: :categorizations,
           after_add: proc {|d, c|
             d.categorizations.where(category_id: c.id, categorized_as: nil).first.update_columns(categorized_as: d.class.name)
           }
  has_many :event_categories, -> { where(GpCategory::Categorization.arel_table[:categorized_as].eq('GpCalendar::Event')) },
           class_name: 'GpCategory::Category', through: :categorizations, source: :category,
           after_add: proc {|d, c|
             d.categorizations.where(category_id: c.id, categorized_as: nil).first.update_columns(categorized_as: 'GpCalendar::Event')
           }
  has_many :marker_categories, -> { where(GpCategory::Categorization.arel_table[:categorized_as].eq('Map::Marker')) },
           class_name: 'GpCategory::Category', through: :categorizations, source: :category,
           after_add: proc {|d, c|
             d.categorizations.where(category_id: c.id, categorized_as: nil).first.update_columns(categorized_as: 'Map::Marker')
           }
  has_and_belongs_to_many :tags, ->(doc) {
                              c = doc.content
                              c && c.tag_related? && c.tag_content_tag ? where(content_id: c.tag_content_tag.id) : where(id: nil)
                            }, class_name: 'Tag::Tag', join_table: 'gp_article_docs_tag_tags'

  after_initialize :set_defaults
  before_save :set_name
  before_save :set_serial_no
  before_save :set_published_at
  before_save :set_display_published_at
  before_save :set_display_updated_at

  after_save     GpArticle::Publisher::DocCallbacks.new, if: :saved_changes?
  before_destroy GpArticle::Publisher::DocCallbacks.new, prepend: true

  after_save     Cms::SearchIndexerCallbacks.new, if: :saved_changes?
  before_destroy Cms::SearchIndexerCallbacks.new, prepend: true

  after_save :replace_public

  attr_accessor :link_check_results, :in_ignore_link_check
  attr_accessor :accessibility_check_results, :in_ignore_accessibility_check, :in_modify_accessibility_check
  attr_accessor :words_with_dictionary_check_results, :in_ignore_words_with_dictionary_check, :in_replace_words_with_dictionary_check

  validates :name, format: { with: /\A[\-\w]*\z/ }
  validates :title, presence: true, length: { maximum: 200 }
  validates :mobile_title, length: { maximum: 200 }
  validates :body, length: { maximum: Zomeki.config.application['gp_article.body_limit'].to_i }
  validates :mobile_body, length: { maximum: Zomeki.config.application['gp_article.body_limit'].to_i }
  validates :body_more, length: { maximum: Zomeki.config.application['gp_article.body_limit'].to_i }
  validates :state, presence: true
  validates :filename_base, presence: true
  validates :body_for_mobile, byte_length: { maximum: Zomeki.config.application['gp_article.body_limit_for_mobile'].to_i,
                                             message: :too_long_byte_for_mobile,
                                             attribute: -> { mobile_body.present? ? :mobile_body : :body } },
                              if: -> { site.use_mobile_feature? }

  validate :validate_name, if: -> { name.present? }
  validate :validate_template_values, if: -> { !state_draft?}
  validate :validate_accessibility_check, if: -> { !state_draft? && errors.blank? }
  validate :validate_broken_link_existence, if: -> { !state_draft? && errors.blank? }
  validate :validate_words_with_dictionary_check, if: -> { !state_draft? && errors.blank? }

  validates_with Sys::TaskValidator, if: -> { !state_draft? }
  validates_with Cms::ContentNodeValidator, if: -> { state_approvable? || state_approved? || state_prepared? || state_public? }

  scope :public_state, -> { where(state: 'public') }
  scope :mobile, ->(m) { m ? where(terminal_mobile: true) : where(terminal_pc_or_smart_phone: true) }
  scope :visible_in_list, -> { where(feature_1: true) }
  scope :visible_in_feed, -> {
    #target.present? && href.present?
    where(arel_table[:feed_state].eq('visible')
          .and(arel_table[:href].eq(nil).or(arel_table[:href].eq(''))
          .and(arel_table[:target].eq(nil).or(arel_table[:target].eq('')))))
  }
  scope :categorized_into, ->(categories, categorized_as: 'GpArticle::Doc', alls: false) {
    cats = GpCategory::Categorization.select(:categorizable_id)
                                     .where(categorized_as: categorized_as, categorizable_type: self.name)
    if alls
      Array(categories).inject(all) { |rel, c| rel.where(id: cats.where(category_id: c)) }
    else
      where(id: cats.where(category_id: categories))
    end
  }
  scope :organized_into, ->(groups) {
    joins(creator: :group).where(sys_groups: { id: groups })
  }

  def deletable?
    super && !state_public?
  end

  def filename_for_uri
    if filename_base == 'index'
      ''
    else
      "#{filename_base}.html"
    end
  end

  def public_dir
    return unless node = content.node
    "#{node.public_uri}#{name}/"
  end

  def public_uri
    return unless dir = public_dir
    "#{dir}#{filename_for_uri}"
  end

  def public_path
    return unless dir = public_dir
    "#{site.public_path}#{dir}#{filename_base}.html"
  end

  def public_smart_phone_path
    return unless dir = public_dir
    "#{site.public_smart_phone_path}#{dir}#{filename_base}.html"
  end

  def preview_uri(terminal: nil, params: {})
    return if terminal == :mobile && !terminal_mobile
    return if terminal.in?([nil, :pc, :smart_phone]) && !terminal_pc_or_smart_phone
    return if (dir = public_dir).blank?

    flag = { mobile: 'm', smart_phone: 's' }[terminal]
    query = "?#{params.to_query}" if params.present?
    "/_preview/#{format('%04d', site.id)}#{flag}#{dir}preview/#{id}/#{filename_for_uri}#{query}"
  end

  def file_base_uri
    if state_public?
      public_uri
    else
      admin_uri + '/'
    end
  end

  def organization_group
    return @organization_group if defined? @organization_group
    @organization_group =
      if content.organization_content_group && creator.group
        content.organization_content_group.groups.detect{|og| og.sys_group_code == creator.group.code}
      else
        nil
      end
  end

  def external_link?
    target.present? && href.present?
  end

  def bread_crumbs(doc_node)
    crumbs = []

    categories.public_state.each do |category|
      category_type = category.category_type
      if (node = category.content.public_node)
        crumb = node.bread_crumbs.crumbs.first
        crumb << [category_type.title, "#{node.public_uri}#{category_type.name}/"]
        category.ancestors.each {|a| crumb << [a.title, "#{node.public_uri}#{category_type.name}/#{a.path_from_root_category}/"] }
        crumbs << crumb
      end
    end

    if organization = content.organization_content_group
      if (node = organization.public_node) &&
         (og = organization.groups.where(state: 'public', sys_group_code: creator.group.try(:code)).first)
        crumb = node.bread_crumbs.crumbs.first
        og.ancestors.each {|a| crumb << [a.sys_group.name, "#{node.public_uri}#{a.path_from_root}/"] }
        crumbs << crumb
      end
    end

    if crumbs.empty?
      doc_node.routes.each do |r|
        crumb = []
        r.each {|i| crumb << [i.title, i.public_uri] }
        crumbs << crumb
      end
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def duplicate(dup_for=nil)
    new_attributes = self.attributes

    new_attributes[:state] = 'draft'
    new_attributes[:id] = nil
    new_attributes[:created_at] = nil
    new_attributes[:updated_at] = nil
    new_attributes[:recognized_at] = nil
    new_attributes[:prev_edition_id] = nil

    new_doc = self.class.new(new_attributes)

    case dup_for
    when :replace
      new_doc.prev_edition = self
      self.tasks.each do |task|
        new_doc.tasks.build(site_id: task.site_id, name: task.name, process_at: task.process_at) if task.state_queued?
      end
      new_doc.creator_attributes = { group_id: creator.group_id, user_id: creator.user_id }
      new_doc.display_updated_at = nil unless keep_display_updated_at
    else
      new_doc.name = nil
      new_doc.title = new_doc.title.gsub(/^(【複製】)*/, '【複製】')
      new_doc.display_updated_at = nil
      new_doc.published_at = nil
      new_doc.display_published_at = nil
      new_doc.serial_no = nil
    end

    editable_groups.each do |eg|
      new_doc.editable_groups.build(group_id: eg.group_id)
    end

    related_docs.each do |rd|
      new_doc.related_docs.build(name: rd.name, content_id: rd.content_id)
    end

    inquiries.each_with_index do |inquiry, i|
      attrs = inquiry.attributes
      attrs[:id] = nil
      attrs[:group_id] = Core.user.group_id if i == 0 && !Core.user.has_auth?(:manager)
      new_doc.inquiries.build(attrs)
    end

    periods.each do |period|
      new_doc.periods.build(period.attributes.slice('started_on', 'ended_on'))
    end

    maps.each do |map|
      new_map = new_doc.maps.build(map.attributes.slice('name', 'title', 'map_lat', 'map_lng', 'map_zoom'))
      map.markers.each do |marker|
        new_map.markers.build(marker.attributes.slice('name', 'lat', 'lng'))
      end
    end

    importations.each do |importation|
      new_doc.importations.build(importation.attributes.slice('source_url'))
    end

    transaction do
      new_doc.save(validate: false)

      files.each do |f|
        f.duplicate(file_attachable: new_doc)
      end

      new_doc.categories = self.categories
      new_doc.event_categories = self.event_categories
      new_doc.marker_categories = self.marker_categories
      new_doc.categorizations.each do |new_c|
        self_c = self.categorizations.where(category_id: new_c.category_id, categorized_as: new_c.categorized_as).first
        new_c.update_column(:sort_no, self_c.sort_no)
      end
    end

    return new_doc
  end

  def publishable?
    state.in?(%w(approved prepared)) && (editable? || approval_participators.include?(Core.user))
  end

  def extract_links
    extracted_links = super
    if template
      rich_text_items = template.items.select { |item| item.item_type == 'rich_text' }
      rich_text_items.each do |item|
        links = Util::Link.extract_links(template_values[item.name])
        links.each { |link| link[:column] = :template_values }
        extracted_links += links
      end
    end
    extracted_links
  end

  def check_accessibility
    results = Util::AccessibilityChecker.check(body)
    if template
      rich_text_items = template.items.select { |item| item.item_type == 'rich_text' }
      rich_text_items.each do |item|
        results += Util::AccessibilityChecker.check(template_values[item.name])
      end
    end
    results
  end
  
  def check_words_width_dictionary
    return if content.word_dictionary.blank?
    results = []
    dic = Cms::WordDictionaryService.new(content.word_dictionary)
    [:body, :mobile_body].each do |column|
      text = read_attribute(column)
      next if text.blank?
      
      result = dic.check(text) 
      results.push([column, result]) if result
    end
    results
  end

  def modify_accessibility
    self.body = Util::AccessibilityChecker.modify(body)
    if template
      rich_text_items = template.items.select { |item| item.item_type == 'rich_text' }
      rich_text_items.each do |item|
        template_values[item.name] = Util::AccessibilityChecker.modify(template_values[item.name])
      end
    end
  end

  def replace_words_with_dictionary
    return if content.word_dictionary.blank?

    dic = Cms::WordDictionaryService.new(content.word_dictionary)
    [:body, :mobile_body].each do |column|
      text = read_attribute(column)
      self[column] = dic.replace(text) if text.present?
    end
  end

  def body_for_mobile
    body_doc = Nokogiri::XML("<bory_root>#{self.mobile_body.presence || self.body}</bory_root>")
    body_doc.xpath('//img').each {|img| img.replace(img.attribute('alt').try(:value).to_s) }
    body_doc.xpath('//a').each {|a| a.replace(a.text) if a.attribute('href').try(:value) =~ %r!^file_contents/! }
    body_doc.xpath('/bory_root').to_xml.gsub(%r!^<bory_root>|</bory_root>$!, '')
  end

  def will_replace?
    prev_edition && (state_draft? || state_approvable? || state_approved? || state_prepared?)
  end

  def will_be_replaced?
    next_edition && state_public?
  end

  def qrcode_visible?
    super && content && content.qrcode_related?
  end

  def lang_text
    content.lang_options.rassoc(lang).try(:first)
  end

  def trash
    self.state = 'trashed'
    save(validate: false)
  end

  def untrash
    if prev_edition_id && self.class.where(prev_edition_id: prev_edition_id).where.not(id: id, state: 'trashed').exists?
      errors.add(:next_edition, :taken)
      return false
    end
    self.state = 'draft'
    save(validate: false)
  end

  private

  def validate_name
    doc = self.class.where(content_id: content_id, name: name)
    doc = doc.where.not(serial_no: serial_no) if serial_no
    errors.add(:name, :taken) if doc.exists?
  end

  def validate_broken_link_existence
    return unless content.link_check_enabled?
    return if in_ignore_link_check == '1'

    results = check_links
    if results.any? {|r| !r[:result] }
      self.link_check_results = results
      errors.add(:base, 'リンクチェック結果を確認してください。')
    end
  end

  def validate_accessibility_check
    return unless content.accessibility_check_enabled?

    modify_accessibility if in_modify_accessibility_check == '1'
    results = check_accessibility
    if (results.present? && in_ignore_accessibility_check != '1') || errors.present?
      self.accessibility_check_results = results
      errors.add(:base, 'アクセシビリティチェック結果を確認してください。')
    end
  end

  def validate_words_with_dictionary_check
    return if content.word_dictionary.blank?

    replace_words_with_dictionary if in_replace_words_with_dictionary_check == '1' && in_ignore_words_with_dictionary_check != '1'
    results = check_words_width_dictionary
    if (results.present? && in_ignore_words_with_dictionary_check != '1') || errors.present?
      self.words_with_dictionary_check_results = results
      errors.add(:base, '単語置換チェック結果を確認してください。')
    end
  end

  def set_name
    return if self.name.present?
    date = (created_at || Time.now).strftime('%Y%m%d')
    seq = Util::Sequencer.next_id('gp_article_docs', version: date, site_id: content.site_id)
    self.name = Util::String::CheckDigit.check(date + format('%04d', seq))
  end

  def set_published_at
    self.published_at ||= Time.now if self.state == 'public'
  end

  def set_defaults
    set_defaults_from_content if new_record? && content
  end

  def set_defaults_from_content
    self.qrcode_state = content.qrcode_default_state if self.has_attribute?(:qrcode_state) && self.qrcode_state.nil?
    self.feature_1 = content.feature_settings[:feature_1] if self.has_attribute?(:feature_1) && self.feature_1.nil?
    self.feature_2 = content.feature_settings[:feature_2] if self.has_attribute?(:feature_2) && self.feature_2.nil?
    self.feed_state ||= content.feature_settings[:feed_state] if self.has_attribute?(:feed_state)

    if !content.setting_value(:basic_setting).blank?
      self.layout_id ||= content.setting_extra_value(:basic_setting, :default_layout_id).to_i
      self.concept_id ||= content.setting_value(:basic_setting).to_i
    elsif (node = content.public_node)
      self.layout_id ||= node.layout_id
      self.concept_id ||= node.concept_id
    else
      self.concept_id ||= content.concept_id
    end
  end

  def set_display_published_at
    if (publish_task = tasks.detect(&:publish_task?)) && state == 'approvable'
      self.display_published_at ||= publish_task.process_at
    end
    self.display_published_at ||= published_at
  end

  def set_display_updated_at
    if state == 'public' && (!keep_display_updated_at || display_updated_at.blank?)
      self.display_updated_at = Time.now
    end
  end

  def set_serial_no
    return if self.serial_no.present?
    seq = Util::Sequencer.next_id('gp_article_doc_serial_no', version: self.content_id, site_id: content.site_id)
    self.serial_no = seq
  end

  def replace_public
    prev_edition.destroy if state_public? && prev_edition
  end

  class << self
    def cleanup
      days = Sys::Setting.trash_keep_days
      return unless days

      docs = self.where(state: 'trashed').date_before(:updated_at, days.days.ago)
      docs.find_each(batch_size: 100) do |doc|
        doc.destroy
      end
    end
  end

  concerning :Publication do
    included do
      after_destroy :close_page, if: -> { state_public? }

      define_model_callbacks :publish_files
      after_publish_files Cms::FileTransferCallbacks.new([:public_path, :public_smart_phone_path], recursive: true)
    end

    def publish
      self.state = 'public' unless state_public?
      transaction do
        return false unless save(validate: false)
        run_callbacks :publish_files do
          rebuild
        end
      end
    end

    def rebuild
      return false unless state_public?
      return true unless terminal_pc_or_smart_phone

      rendered = Cms::RenderService.new(content.site).render_public(public_uri)
      return true unless publish_page(rendered, path: public_path)
      publish_files
      publish_qrcode

      if content.site.use_kana?
        rendered = Cms::Lib::Navi::Kana.convert(rendered, content.site_id)
        publish_page(rendered, path: "#{public_path}.r", dependent: :ruby)
      end

      if content.site.publish_for_smart_phone?
        rendered = Cms::RenderService.new(content.site).render_public(public_uri, agent_type: :smart_phone)
        publish_page(rendered, path: public_smart_phone_path, dependent: :smart_phone)
        publish_smart_phone_files
        publish_smart_phone_qrcode
      end

      rebuild_search_texts

      return true
    end

    def close
      self.state = 'closed' if self.state_public?
      transaction do
        return false unless save(validate: false)
        close_page
        close_files
      end
      return true
    end

    def close_page(options={})
      return true if will_replace?
      return false unless super

      paths = [public_path, public_smart_phone_path].select(&:present?)
      paths.each { |path| FileUtils.rm_rf(::File.dirname(path)) if path.present? }
      return true
    end
  end
end
