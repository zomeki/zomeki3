class GpArticle::Doc < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Editor
  include Sys::Model::Rel::EditableGroup
  include Sys::Model::Rel::File
  include Sys::Model::Rel::Task
  include Cms::Model::Site
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Cms::Model::Base::Qrcode
  include Cms::Model::Rel::Content
  include Cms::Model::Rel::Concept
  include Cms::Model::Rel::Inquiry
  include Cms::Model::Rel::Map
  include Cms::Model::Rel::Bracket
  include Cms::Model::Rel::Link
  include Cms::Model::Rel::PublishUrl
  include Cms::Model::Rel::SearchText
  include Cms::Model::Rel::Importation

  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::EditableGroup

  include GpArticle::Model::Rel::Doc
  include GpArticle::Model::Rel::Category
  include GpArticle::Model::Rel::Tag
  include GpArticle::Model::Rel::RelatedDoc
  include Approval::Model::Rel::Approval
  include GpTemplate::Model::Rel::Template

  include StateText

  self.linkable_columns = [:body, :mobile_body, :body_more]
  self.searchable_columns = [:body]

  TARGET_OPTIONS = [['無効', ''], ['同一ウィンドウ', '_self'], ['別ウィンドウ', '_blank'], ['添付ファイル', 'attached_file']]
  EVENT_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  MARKER_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  OGP_TYPE_OPTIONS = [['article', 'article']]
  FEATURE_1_OPTIONS = [['表示', true], ['非表示', false]]
  FEATURE_2_OPTIONS = [['表示', true], ['非表示', false]]

  default_scope { where.not(state: 'archived') }

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'
  validates :content_id, :presence => true

  # Page
  belongs_to :layout, :foreign_key => :layout_id, :class_name => 'Cms::Layout'

  has_many :operation_logs, -> { where(item_model: 'GpArticle::Doc') },
    foreign_key: :item_id, class_name: 'Sys::OperationLog'

  belongs_to :prev_edition, :class_name => self.name
  has_one :next_edition, :foreign_key => :prev_edition_id, :class_name => self.name

  belongs_to :marker_icon_category, :class_name => 'GpCategory::Category'

  has_many :categorizations, :class_name => 'GpCategory::Categorization', :as => :categorizable, :dependent => :destroy
  has_many :categories, -> { where(GpCategory::Categorization.arel_table[:categorized_as].eq('GpArticle::Doc')) },
           :class_name => 'GpCategory::Category', :through => :categorizations,
           :after_add => proc {|d, c|
             d.categorizations.where(category_id: c.id, categorized_as: nil).first.update_columns(categorized_as: d.class.name)
           }
  has_many :event_categories, -> { where(GpCategory::Categorization.arel_table[:categorized_as].eq('GpCalendar::Event')) },
           :class_name => 'GpCategory::Category', :through => :categorizations, :source => :category,
           :after_add => proc {|d, c|
             d.categorizations.where(category_id: c.id, categorized_as: nil).first.update_columns(categorized_as: 'GpCalendar::Event')
           }
  has_many :marker_categories, -> { where(GpCategory::Categorization.arel_table[:categorized_as].eq('Map::Marker')) },
           :class_name => 'GpCategory::Category', :through => :categorizations, :source => :category,
           :after_add => proc {|d, c|
             d.categorizations.where(category_id: c.id, categorized_as: nil).first.update_columns(categorized_as: 'Map::Marker')
           }
  has_and_belongs_to_many :tags, ->(doc) {
                              c = doc.content
                              c && c.tag_related? && c.tag_content_tag ? where(content_id: c.tag_content_tag.id) : where(id: nil)
                            }, class_name: 'Tag::Tag', join_table: 'gp_article_docs_tag_tags'

  has_many :holds, :as => :holdable, :dependent => :destroy

  after_initialize :set_defaults
  before_save :set_name
  before_save :set_serial_no
  before_save :set_published_at
  before_save :set_display_attributes
  before_save :replace_public

  after_save     GpArticle::Publisher::DocCallbacks.new, if: :changed?
  before_destroy GpArticle::Publisher::DocCallbacks.new

  after_save     Cms::SearchIndexerCallbacks.new, if: :changed?
  before_destroy Cms::SearchIndexerCallbacks.new

  attr_accessor :link_check_results, :in_ignore_link_check
  attr_accessor :accessibility_check_results, :in_ignore_accessibility_check, :in_modify_accessibility_check

  validates :title, presence: true, length: { maximum: 200 }
  validates :mobile_title, length: { maximum: 200 }
  validates :body, length: { maximum: Zomeki.config.application['gp_article.body_limit'].to_i }
  validates :mobile_body, length: { maximum: Zomeki.config.application['gp_article.body_limit'].to_i }
  validates :body_more, length: { maximum: Zomeki.config.application['gp_article.body_limit'].to_i }
  validates :state, presence: true
  validates :filename_base, presence: true
  validates :body_for_mobile, byte_length: { maximum: Zomeki.config.application['gp_article.body_limit_for_mobile'].to_i,
                                             message: :too_long_byte_for_mobile,
                                             attribute: -> { mobile_body.present? ? :mobile_body : :body } }

  validate :name_validity, if: -> { name.present? }
  validate :event_dates_range
  validate :validate_accessibility_check, if: -> { !state_draft? && errors.blank? }
  validate :validate_broken_link_existence, if: -> { !state_draft? && errors.blank? }

  validates_with Cms::ContentNodeValidator, if: -> { state_approvable? },
                                           message: '記事コンテンツのディレクトリが作成されていないため、承認依頼が行えません。'
  validates_with Cms::ContentNodeValidator, if: -> { state_public? },
                                           message: '記事コンテンツのディレクトリが作成されていないため、即時公開が行えません。'

  scope :public_state, -> { where(state: 'public') }
  scope :mobile, ->(m) { m ? where(terminal_mobile: true) : where(terminal_pc_or_smart_phone: true) }
  scope :display_published_after, ->(date) { where(arel_table[:display_published_at].gteq(date)) }
  scope :visible_in_list, -> { where(feature_1: true) }
  scope :event_scheduled_between, ->(start_date, end_date, category_ids = nil) {
    rel = dates_intersects(:event_started_on, :event_ended_on, start_date.try(:beginning_of_day), end_date.try(:end_of_day))
    rel = rel.categorized_into_event(category_ids) if category_ids.present?
    rel
  }
  scope :categorized_into, ->(category_ids) {
    cats = GpCategory::Categorization.arel_table
    where(id: GpCategory::Categorization.select(:categorizable_id)
      .where(cats[:categorized_as].eq('GpArticle::Doc'))
      .where(cats[:category_id].in(category_ids)))
  }
  scope :categorized_into_all, ->(category_ids) {
    cats = GpCategory::Categorization.arel_table
    category_ids.inject(all) do |rel, category_id|
      rel = rel.where(id: GpCategory::Categorization.select(:categorizable_id)
        .where(cats[:categorized_as].eq('GpArticle::Doc'))
        .where(cats[:category_id].eq(category_id)))
    end
  }
  scope :categorized_into_event, ->(category_ids) {
    cats = GpCategory::Categorization.arel_table
    category_ids.inject(all) do |rel, category_id|
      rel = rel.where(id: GpCategory::Categorization.select(:categorizable_id)
        .where(cats[:categorized_as].eq('GpCalendar::Event'))
        .where(cats[:category_id].eq(category_id)))
    end
  }
  scope :organized_into, ->(group_ids) {
    groups = Sys::Group.arel_table
    joins(creator: :group).where(groups[:id].in(group_ids))
  }

  def public_path
    return '' if public_uri.blank?
    "#{content.public_path}#{public_uri(without_filename: true)}#{filename_base}.html"
  end

  def public_smart_phone_path
    return '' if public_uri.blank?
    "#{content.public_path}/_smartphone#{public_uri(without_filename: true)}#{filename_base}.html"
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

  def public_uri(without_filename: false, with_closed_preview: false)
    uri =
      if content.organization_content_related? && organization_group
        "#{organization_group.public_uri}docs/#{name}/"
      elsif with_closed_preview && content.main_node
        "#{content.main_node.public_uri}#{name}/"
      elsif !with_closed_preview && content.public_node
        "#{content.public_node.public_uri}#{name}/"
      end
    return '' unless uri
    without_filename || filename_base == 'index' ? uri : "#{uri}#{filename_base}.html"
  end

  def public_full_uri(without_filename: false)
    uri =
      if content.organization_content_related? && organization_group
        "#{organization_group.public_full_uri}docs/#{name}/"
      elsif content.public_node
        "#{content.public_node.public_full_uri}#{name}/"
      end
    return '' unless uri
    without_filename || filename_base == 'index' ? uri : "#{uri}#{filename_base}.html"
  end

  def preview_uri(site: nil, mobile: false, smart_phone: false, without_filename: false, **params)
    base_uri = public_uri(without_filename: true, with_closed_preview: true)
    return nil if base_uri.blank?

    site ||= content.site
    params = params.map{|k, v| "#{k}=#{v}" }.join('&')
    filename = without_filename || filename_base == 'index' ? '' : "#{filename_base}.html"
    page_flag = mobile ? 'm' : smart_phone ? 's' : ''

    path = "_preview/#{format('%04d', site.id)}#{page_flag}#{base_uri}preview/#{id}/#{filename}#{params.present? ? "?#{params}" : ''}"
    "#{site.main_admin_uri}#{path}"
  end

  def file_content_uri
    if state_public?
      %Q(#{public_uri}file_contents/)
    else
      %Q(#{content.admin_uri}/#{id}/file_contents/)
    end
  end

  def state_draft?
    state == 'draft'
  end

  def state_approvable?
    state == 'approvable'
  end

  def state_approved?
    state == 'approved'
  end

  def state_prepared?
    state == 'prepared'
  end

  def state_public?
    state == 'public'
  end

  def state_closed?
    state == 'closed'
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
      attrs[:group_id] = Core.user.group_id if i == 0
      new_doc.inquiries.build(attrs)
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
      new_doc.save!

      files.each do |f|
        new_attributes = f.attributes
        new_attributes[:id] = nil
        new_file = Sys::File.new(new_attributes)
        new_file.file = Sys::Lib::File::NoUploadedFile.new(f.upload_path, mime_type: new_file.mime_type)
        new_file.file_attachable = new_doc
        new_file.save
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

  def formated_display_published_at
    display_published_at.try(:strftime, content.date_style)
  end

  def formated_display_updated_at
    display_updated_at.try(:strftime, content.date_style)
  end

  def default_map_position
    [content.map_coordinate, content.site.map_coordinate].lazy.each do |pos|
      p = pos.to_s.split(',').map(&:strip)
      return p if p.size == 2
    end
    super
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

    dic = Cms::Admin::WordDictionaryService.new(content.word_dictionary)
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

  def og_type_text
    OGP_TYPE_OPTIONS.detect{|o| o.last == self.og_type }.try(:first).to_s
  end

  def target_text
    TARGET_OPTIONS.detect{|o| o.last == self.target }.try(:first).to_s
  end

  def event_state_text
    EVENT_STATE_OPTIONS.detect{|o| o.last == self.event_state }.try(:first).to_s
  end

  def marker_state_text
    MARKER_STATE_OPTIONS.detect{|o| o.last == self.marker_state }.try(:first).to_s
  end

  def feature_1_text
    FEATURE_1_OPTIONS.detect{|o| o.last == self.feature_1 }.try(:first).to_s
  end

  def feature_2_text
    FEATURE_2_OPTIONS.detect{|o| o.last == self.feature_2 }.try(:first).to_s
  end

  def qrcode_visible?
    super && content && content.qrcode_related?
  end

  def event_state_visible?
    event_state == 'visible'
  end

  def lang_text
    content.lang_options.rassoc(lang).try(:first)
  end

  def link_to_options
    if target.present?
      if href.present?
        if target == 'attached_file'
          if (file = files.find_by(name: href))
            ["#{public_uri}file_contents/#{file.name}", target: '_blank']
          else
            nil
          end
        else
          [href, target: target]
        end
      else
        nil
      end
    else
      [public_uri]
    end
  end

  private

  def name_validity
    errors.add(:name, :invalid) if name !~ /^[\-\w]*$/

    doc = self.class.where(content_id: content_id, name: name)
    doc = doc.where.not(serial_no: serial_no) if serial_no
    errors.add(:name, :taken) if doc.exists?
  end

  def set_name
    return if self.name.present?
    date = if created_at
             created_at.strftime('%Y%m%d')
           else
             Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
           end
    seq = Util::Sequencer.next_id('gp_article_docs', version: date, site_id: content.site_id)
    self.name = Util::String::CheckDigit.check(date + format('%04d', seq))
  end

  def set_published_at
    self.published_at ||= Core.now if self.state == 'public'
  end

  def set_defaults
    self.target       ||= TARGET_OPTIONS.first.last if self.has_attribute?(:target)
    self.event_state  ||= 'hidden'                  if self.has_attribute?(:event_state)
    self.marker_state ||= 'hidden'                  if self.has_attribute?(:marker_state)
    self.terminal_pc_or_smart_phone = true if self.has_attribute?(:terminal_pc_or_smart_phone) && self.terminal_pc_or_smart_phone.nil?
    self.terminal_mobile            = true if self.has_attribute?(:terminal_mobile) && self.terminal_mobile.nil?
    self.body_more_link_text ||= '続きを読む' if self.has_attribute?(:body_more_link_text)
    self.filename_base ||= 'index' if self.has_attribute?(:filename_base)

    set_defaults_from_content if new_record?
  end

  def set_defaults_from_content
    return unless content

    self.qrcode_state = content.qrcode_default_state if self.has_attribute?(:qrcode_state) && self.qrcode_state.nil?
    self.feature_1 = content.feature_settings[:feature_1] if self.has_attribute?(:feature_1) && self.feature_1.nil?
    self.feature_2 = content.feature_settings[:feature_2] if self.has_attribute?(:feature_2) && self.feature_2.nil?

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

  def set_display_attributes
    self.display_published_at = published_at if display_published_at.nil?
    self.display_updated_at = updated_at if display_updated_at.nil? || !keep_display_updated_at
  end

  def set_serial_no
    return if self.serial_no.present?
    seq = Util::Sequencer.next_id('gp_article_doc_serial_no', version: self.content_id, site_id: content.site_id)
    self.serial_no = seq
  end

  def validate_platform_dependent_characters
    [:title, :body, :mobile_title, :mobile_body].each do |attr|
      if chars = Util::String.search_platform_dependent_characters(send(attr))
        errors.add attr, :platform_dependent_characters, :chars => chars
      end
    end
  end

  def event_dates_range
    return if self.event_started_on.blank? && self.event_ended_on.blank?
    self.event_started_on = self.event_ended_on if self.event_started_on.blank?
    self.event_ended_on = self.event_started_on if self.event_ended_on.blank?
    errors.add(:event_ended_on, "が#{self.class.human_attribute_name :event_started_on}を過ぎています。") if self.event_ended_on < self.event_started_on
  end

  def validate_broken_link_existence
    return unless content.site.link_check_enabled?
    return if in_ignore_link_check == '1'

    results = check_links
    if results.any? {|r| !r[:result] }
      self.link_check_results = results
      errors.add(:base, 'リンクチェック結果を確認してください。')
    end
  end

  def validate_accessibility_check
    return unless content.site.accessibility_check_enabled?

    modify_accessibility if in_modify_accessibility_check == '1'
    results = check_accessibility
    if (results.present? && in_ignore_accessibility_check != '1') || errors.present?
      self.accessibility_check_results = results
      errors.add(:base, 'アクセシビリティチェック結果を確認してください。')
    end
  end

  def replace_public
    prev_edition.destroy if state_public? && prev_edition
  end

  concerning :Publication do
    included do
      after_destroy :close_page

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

      rendered = Cms::Admin::RenderService.new(content.site).render_public(public_uri)
      return true unless publish_page(rendered, path: public_path)
      publish_files
      publish_qrcode

      if content.site.use_kana?
        rendered = Cms::Lib::Navi::Kana.convert(rendered, content.site_id)
        publish_page(rendered, path: "#{public_path}.r", dependent: :ruby)
      end

      if content.site.publish_for_smart_phone?
        rendered = Cms::Admin::RenderService.new(content.site).render_public(public_uri, agent_type: :smart_phone)
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
