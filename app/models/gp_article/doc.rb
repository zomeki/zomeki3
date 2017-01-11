class GpArticle::Doc < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Editor
  include Sys::Model::Rel::EditableGroup
  include Sys::Model::Rel::File
  include Sys::Model::Rel::Task
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Cms::Model::Rel::Inquiry
  include Cms::Model::Rel::Map
  include Cms::Model::Rel::Bracket

  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::EditableGroup

  include GpArticle::Model::Rel::Doc
  include GpArticle::Model::Rel::Category
  include GpArticle::Model::Rel::Tag
  include Approval::Model::Rel::Approval
  include GpTemplate::Model::Rel::Template
  include GpArticle::Model::Rel::RelatedDoc
  include Cms::Model::Rel::PublishUrl
  include Cms::Model::Rel::Link

  include StateText
  include GpArticle::Docs::PublishQueue
  include GpArticle::Docs::Preload

  STATE_OPTIONS = [['下書き保存', 'draft'], ['承認依頼', 'approvable'], ['即時公開', 'public']]
  TARGET_OPTIONS = [['無効', ''], ['同一ウィンドウ', '_self'], ['別ウィンドウ', '_blank'], ['添付ファイル', 'attached_file']]
  EVENT_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  MARKER_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  OGP_TYPE_OPTIONS = [['article', 'article']]
  FEATURE_1_OPTIONS = [['表示', true], ['非表示', false]]
  FEATURE_2_OPTIONS = [['表示', true], ['非表示', false]]
  QRCODE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  EVENT_WILL_SYNC_OPTIONS = [['同期する', 'enabled'], ['同期しない', 'disabled']]

  default_scope { where.not(state: 'archived') }
  scope :public_state, -> { where(state: 'public') }
  scope :mobile, ->(m) { m ? where(terminal_mobile: true) : where(terminal_pc_or_smart_phone: true) }
  scope :display_published_after, ->(date) { where(arel_table[:display_published_at].gteq(date)) }

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'
  validates :content_id, :presence => true

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
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
  has_many :comments, :dependent => :destroy

  before_save :set_name
  before_save :set_published_at
  before_save :replace_public
  before_save :set_serial_no
  before_destroy :keep_edition_relation
  after_destroy :close_page

  attr_accessor :link_check_results, :in_ignore_link_check
  attr_accessor :accessibility_check_results, :in_ignore_accessibility_check, :in_modify_accessibility_check

  validates :title, :presence => true, :length => {maximum: 200}
  validates :mobile_title, :length => {maximum: 200}
  validates :body, :length => {maximum: 300000}
  validates :mobile_body, :length => {maximum: 300000}
  validates :state, :presence => true
  validates :filename_base, :presence => true

  validate :name_validity
  validate :node_existence
  validate :event_dates_range
  validate :body_limit_for_mobile
  validate :validate_accessibility_check, if: -> { !state_draft? && errors.blank? }
  validate :validate_broken_link_existence, if: -> { !state_draft? && errors.blank? }

  after_initialize :set_defaults
  after_save :set_display_attributes

  scope :visible_in_list, -> { where(feature_1: true) }
  scope :event_scheduled_between, ->(start_date, end_date, category_ids) {
    rel = all
    rel = rel.where(arel_table[:event_ended_on].gteq(start_date)) if start_date.present?
    rel = rel.where(arel_table[:event_started_on].lt(end_date + 1)) if end_date.present?
    rel = rel.categorized_into_event(category_ids) if category_ids.present?
    rel
  }
  scope :content_and_criteria, ->(content, criteria) {
    rel = all
    rel = rel.where(arel_table[:content_id].eq(content.id)) if content

    rel = rel.with_target(criteria[:target]) if criteria[:target].present?
    rel = rel.with_target_state(criteria[:target_state]) if criteria[:target_state].present?

    [:state, :event_state, :marker_state].each do |key|
      rel = rel.where(key => criteria[key]) if criteria[key].present?
    end

    if criteria[:creator_user_name].present?
      rel = rel.operated_by_user_name('create', criteria[:creator_user_name])
    end

    if criteria[:creator_group_id].present?
      rel = rel.operated_by_group('create', criteria[:creator_group_id])
    end

    if criteria[:category_ids].present? && (category_ids = criteria[:category_ids].select(&:present?)).present?
      rel = rel.categorized_into_all(category_ids)
    end

    if criteria[:user_operation].present?
      rel = rel.operated_by_user_name(criteria[:user_operation], criteria[:user_name]) if criteria[:user_name].present?
      rel = rel.operated_by_group(criteria[:user_operation], criteria[:user_group_id]) if criteria[:user_group_id].present?
    end

    if criteria[:date_column].present? && criteria[:date_operation].present?
      dates = criteria[:dates].to_a.map { |date| date.present? ? (Date.parse(date) rescue nil) : nil }.compact
      rel = rel.search_date_column(criteria[:date_column], criteria[:date_operation], dates)
    end

    if criteria[:assocs].present?
      criteria[:assocs].select(&:present?).each { |assoc| rel = rel.joins(assoc.to_sym) }
    end

    if criteria[:tasks].present?
      criteria[:tasks].select(&:present?).each { |task| rel = rel.with_task_name(task) }
    end

    if criteria[:texts].present?
      criteria[:texts].select(&:present?).each do |column|
        rel = rel.where.not(arel_table[column].eq('')).where.not(arel_table[column].eq(nil))
      end
    end

    search_columns = [:name, :title, :body, :subtitle, :summary, :mobile_title, :mobile_body]
    rel = rel.search_with_logical_query(*search_columns, criteria[:free_word]) if criteria[:free_word].present?

    rel
  }
  scope :with_target, ->(target, user = Core.user) {
    case target
    when 'user'
      creators = Sys::Creator.arel_table
      approval_requests = Approval::ApprovalRequest.arel_table
      assignments = Approval::Assignment.arel_table
      joins(:creator).eager_load(:approval_requests => [:approval_flow => [:approvals => :assignments]])
      .where(
        creators[:user_id].eq(user.id)
        .or(approval_requests[:user_id].eq(user.id)
                        .or(assignments[:user_id].eq(user.id)))
      )
    when 'group'
      editable
    when 'all'
      all
    else
      none
    end
  }
  scope :with_target_state, ->(target_state) {
    case target_state
    when 'processing'
      where(state: %w(draft approvable approved prepared))
    when 'public'
      where(state: 'public')
    when 'finish'
      where(state: 'finish')
    when 'all'
      all
    else
      none
    end
  }
  scope :operated_by_user_name, ->(action, user_name) {
    case action
    when 'create'
      users = Sys::User.arel_table
      joins(creator: :user).where([
        users[:name].matches("%#{user_name}%"),
        users[:name_en].matches("%#{user_name}%")
      ].reduce(:or))
    else
      operation_logs = Sys::OperationLog.arel_table
      users = Sys::User.arel_table
      joins(operation_logs: :user)
        .where(operation_logs[:action].eq(action))
        .where([
          users[:name].matches("%#{user_name}%"),
          users[:name_en].matches("%#{user_name}%")
        ].reduce(:or))
    end
  }
  scope :operated_by_group, ->(action, group_id) {
    case action
    when 'create'
      creators = Sys::Creator.arel_table
      joins(:creator).where(creators[:group_id].eq(group_id))
    else
      operation_logs = Sys::OperationLog.arel_table
      users_groups = Sys::UsersGroup.arel_table
      joins(operation_logs: { user: :users_groups })
        .where(operation_logs[:action].eq(action))
        .where(users_groups[:group_id].eq(group_id))
    end
  }
  scope :search_date_column, ->(column, operation, dates = nil) {
    case operation
    when 'today'
      today = Date.today
      with_date_between(column, today, today)
    when 'this_week'
      today = Date.today
      with_date_between(column, today.beginning_of_week, today.end_of_week)
    when 'last_week'
      last_week = 1.week.ago
      with_date_between(column, last_week.beginning_of_week, last_week.end_of_week)
    when 'equal'
      with_date_between(column, dates[0], dates[0]) if dates[0]
    when 'before'
      where(arel_table[column].lteq(dates[0].end_of_day)) if dates[0]
    when 'after'
      where(arel_table[column].gteq(dates[0].beginning_of_day)) if dates[0]
    when 'between'
      with_date_between(column, dates[0], dates[1]) if dates[0] && dates[1]
    else
      none
    end
  }
  scope :with_date_between, ->(column, date1, date2) {
    where(arel_table[column].in(date1.beginning_of_day..date2.end_of_day))
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

  def public_comments
    comments.public_state
  end

  def prev_edition
    self.class.unscoped { super }
  end

  def prev_editions(docs=[])
    docs << self
    prev_edition.prev_editions(docs) if prev_edition
    return docs
  end

  def next_edition
    self.class.unscoped { super }
  end

  def next_editions(docs=[])
    docs << self
    next_edition.next_editions(docs) if next_edition
    return docs
  end

  def public_path
    return '' if public_uri.blank?
    "#{content.public_path}#{public_uri(without_filename: true)}#{filename_base}.html"
  end

  def public_smart_phone_path
    return '' if public_uri.blank?
    "#{content.public_path}/_smartphone#{public_uri(without_filename: true)}#{filename_base}.html"
  end

  def organization_content_related?
    organization_content = content.organization_content_group
    return organization_content &&
      organization_content.article_related? &&
      organization_content.related_article_content_id == content.id
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
      if organization_content_related? && organization_group
        "#{organization_group.public_uri}docs/#{name}/"
      elsif with_closed_preview && content.doc_node
        "#{content.doc_node.public_uri}#{name}/"
      elsif !with_closed_preview && content.public_node
        "#{content.public_node.public_uri}#{name}/"
      end
    return '' unless uri
    without_filename || filename_base == 'index' ? uri : "#{uri}#{filename_base}.html"
  end

  def public_full_uri(without_filename: false)
    uri =
      if organization_content_related? && organization_group
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

    site ||= ::Page.site
    params = params.map{|k, v| "#{k}=#{v}" }.join('&')
    filename = without_filename || filename_base == 'index' ? '' : "#{filename_base}.html"
    page_flag = mobile ? 'm' : smart_phone ? 's' : ''

    path = "_preview/#{format('%04d', site.id)}#{page_flag}#{base_uri}preview/#{id}/#{filename}#{params.present? ? "?#{params}" : ''}"
    d = Cms::SiteSetting::AdminProtocol.core_domain site, :freeze_protocol => true
    "#{d}#{path}"
  end

  def file_content_uri
    if state_public?
      %Q(#{public_uri}file_contents/)
    else
      %Q(#{content.admin_uri}/#{id}/file_contents/)
    end
  end

  def state_options
    options = if Core.user.has_auth?(:manager) || content.save_button_states.include?('public')
                STATE_OPTIONS
              else
                STATE_OPTIONS.reject{|so| so.last == 'public' }
              end
    if content.approval_related?
      options
    else
      options.reject{|o| o.last == 'approvable' }
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
    state == 'finish'
  end

  def state_archived?
    state == 'archived'
  end

  def close
    @save_mode = :close
    self.state = 'finish' if self.state_public?
    return false unless save(:validate => false)
    close_page
    return true
  end

  def close_page(options={})
    return true if will_replace?
    return false unless super
    publishers.destroy_all unless publishers.empty?
    if p = public_path
      FileUtils.rm_rf(::File.dirname(public_path)) unless p.blank?
    end
    if p = public_smart_phone_path
      FileUtils.rm_rf(::File.dirname(public_smart_phone_path)) unless p.blank?
    end
    return true
  end

  def publish(content)
    @save_mode = :publish
    self.state = 'public' unless self.state_public?
    return false unless save(:validate => false)
    publish_page(content, path: public_path, uri: public_uri)
    publish_files
    publish_qrcode
  end

  def rebuild(content, options={})
    if options[:dependent] == :smart_phone
      return false unless self.content.site.publish_for_smart_phone?
      return false unless self.content.site.spp_all?
    end

    return false unless self.state_public?
    @save_mode = :publish
    publish_page(content, options)
    #TODO: スマートフォン向けファイル書き出し要再検討
    @public_files_path = "#{::File.dirname(public_smart_phone_path)}/file_contents" if options[:dependent] == :smart_phone
    @public_qrcode_path = "#{::File.dirname(public_smart_phone_path)}/qrcode.png" if options[:dependent] == :smart_phone
    result = publish_files
    publish_qrcode
    @public_files_path = nil if options[:dependent] == :smart_phone
    @public_qrcode_path = nil if options[:dependent] == :smart_phone
    return result
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
    new_attributes[:recognized_at] = nil
    new_attributes[:prev_edition_id] = nil

    new_doc = self.class.new(new_attributes)

    case dup_for
    when :replace
      new_doc.prev_edition = self
      self.tasks.each do |task|
        new_doc.tasks.build(site_id: task.site_id, name: task.name, process_at: task.process_at)
      end
      new_doc.creator_attributes = { group_id: creator.group_id, user_id: creator.user_id }
    else
      new_doc.name = nil
      new_doc.title = new_doc.title.gsub(/^(【複製】)*/, '【複製】')
      new_doc.updated_at = nil
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

    new_doc.save!

    files.each do |f|
      new_attributes = f.attributes
      new_attributes[:id] = nil
      Sys::File.new(new_attributes).tap do |new_file|
        new_file.file = Sys::Lib::File::NoUploadedFile.new(f.upload_path, :mime_type => new_file.mime_type)
        new_file.file_attachable = new_doc
        new_file.save
      end
    end

    new_doc.categories = self.categories
    new_doc.event_categories = self.event_categories
    new_doc.marker_categories = self.marker_categories
    new_doc.categorizations.each do |new_c|
      self_c = self.categorizations.where(category_id: new_c.category_id, categorized_as: new_c.categorized_as).first
      new_c.update_column(:sort_no, self_c.sort_no)
    end
    return new_doc
  end

  def editable?
    result = super
    return result unless result.nil? # See "Sys::Model::Auth::EditableGroup"
    return approval_participators.include?(Core.user)
  end

  def publishable?
    super || approval_participators.include?(Core.user)
  end

  def formated_display_published_at
    display_published_at.try(:strftime, content.date_style)
  end

  def formated_display_updated_at
    display_updated_at.try(:strftime, content.date_style)
  end

  def default_map_position
    content.setting_extra_value(:map_relation, :lat_lng).presence || super
  end

  def links_in_body(all=false)
    extract_links(self.body, all)
  end

  def check_links_in_body
    check_links(links_in_body)
  end

  def links_in_mobile_body(all=false)
    extract_links(self.mobile_body, all)
  end

  def links_in_string(str, all=false)
    extract_links(str, all)
  end

  def backlinks
    return self.class.none unless state_public? || state_closed?
    return self.class.none if public_uri.blank?
    links.klass.where(links.table[:url].matches("%#{self.public_uri(without_filename: true).sub(/\/$/, '')}%"))
      .where(linkable_type: self.class.name)
  end

  def backlinked_docs
    return [] if backlinks.blank?
    self.class.where(id: backlinks.pluck(:linkable_id))
  end

  def check_accessibility
    Util::AccessibilityChecker.check(body)
  end

  def modify_accessibility
    self.body = Util::AccessibilityChecker.modify(body)
  end

  def replace_words_with_dictionary
    dic = content.setting_value(:word_dictionary)
    return if dic.blank?

    words = []
    dic.split(/\r\n|\n/).each do |line|
      next if line !~ /,/
      data = line.split(/,/)
      words << [data[0].strip, data[1].strip]
    end

    if body.present?
      words.each {|src, dst| self.body = body.gsub(src, dst) }
    end
    if mobile_body.present?
      words.each {|src, dst| self.mobile_body = mobile_body.gsub(src, dst) }
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

  def was_replaced?
    prev_edition && (state_public? || state_closed?)
  end

  def qrcode_visible?
    return false unless content && content.qrcode_related?
    return false unless self.qrcode_state == 'visible'
    return true
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

  def qrcode_state_text
    QRCODE_OPTIONS.detect{|o| o.last == self.qrcode_state }.try(:first).to_s
  end

  def public_files_path
    return @public_files_path if @public_files_path
    "#{::File.dirname(public_path)}/file_contents"
  end


  def qrcode_path
    return @public_qrcode_path if @public_qrcode_path
    "#{::File.dirname(public_path)}/qrcode.png"
  end

  def qrcode_uri(preview: false)
    if preview
      "#{preview_uri(without_filename: true)}qrcode.png"
    else
      "#{public_uri(without_filename: true)}qrcode.png"
    end
  end

  def event_will_sync?
    event_will_sync == 'enabled'
  end

  def event_will_sync_text
    EVENT_WILL_SYNC_OPTIONS.detect{|o| o.last == event_will_sync }.try(:first).to_s
  end

  def event_state_visible?
    event_state == 'visible'
  end

  def send_broken_link_notification
    backlinked_docs.each do |doc|
      GpArticle::Admin::Mailer.broken_link_notification(self, doc).deliver_now
    end
  end

  def lang_text
    content.lang_options.rassoc(lang).try(:first)
  end

  private

  def name_validity
    if prev_edition
      self.name = prev_edition.name
      return
    end

    errors.add(:name, :invalid) if self.name && self.name !~ /^[\-\w]*$/

    if (doc = self.class.where(name: self.name, state: self.state, content_id: self.content.id).first)
      unless doc.id == self.id || state_archived?
        errors.add(:name, :taken) unless state_public? && prev_edition.try(:state_public?)
      end
    end
  end

  def set_name
    return if self.name.present?
    date = if created_at
             created_at.strftime('%Y%m%d')
           else
             Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
           end
    seq = Util::Sequencer.next_id('gp_article_docs', :version => date)
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
    self.event_will_sync ||= content.event_sync_default_will_sync if self.has_attribute?(:event_will_sync)
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
    self.update_column(:display_published_at, self.published_at) unless self.display_published_at
    self.update_column(:display_updated_at, self.updated_at) if self.display_updated_at.blank? || !self.keep_display_updated_at
  end

  def set_serial_no
    return if self.serial_no.present?
    seq = Util::Sequencer.next_id('gp_article_doc_serial_no', :version => self.content_id)
    self.serial_no = seq
  end

  def node_existence
    unless content.public_node
      case state
      when 'public'
        errors.add(:base, '記事コンテンツのディレクトリが作成されていないため、即時公開が行えません。')
      when 'approvable'
        errors.add(:base, '記事コンテンツのディレクトリが作成されていないため、承認依頼が行えません。')
      end
    end
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

  def extract_links(html, all)
    links = Nokogiri::HTML.parse(html).css('a[@href]').map {|a| {body: a.text, url: a.attribute('href').value} }
    return links if all
    links.select do |link|
      uri = URI.parse(link[:url])
      next true unless uri.absolute?
      [URI::HTTP, URI::HTTPS, URI::FTP].include?(uri.class)
    end
  rescue => evar
    warn_log evar.message
    return []
  end

  def check_links(links)
    links.map{|link|
      uri = URI.parse(link[:url])
      url = unless uri.absolute?
              next unless uri.path =~ /^\//
              "#{content.site.full_uri.sub(/\/$/, '')}#{uri.path}"
            else
              uri.to_s
            end

      res = Util::LinkChecker.check_url(url)
      {body: link[:body], url: url, status: res[:status], reason: res[:reason], result: res[:result]}
    }.compact
  end

  def validate_broken_link_existence
    return if in_ignore_link_check == '1'

    results = check_links_in_body
    if results.any? {|r| !r[:result] }
      self.link_check_results = results
      errors.add(:base, 'リンクチェック結果を確認してください。')
    end
  end

  def publish_qrcode
    return true unless self.state_public?
    return true unless self.qrcode_visible?
    return true if Zomeki.config.application['sys.clean_statics']
    Util::Qrcode.create(self.public_full_uri, self.qrcode_path)
    return true
  end

  def validate_accessibility_check
    return unless Zomeki.config.application['cms.enable_accessibility_check']

    modify_accessibility if in_modify_accessibility_check == '1'
    results = check_accessibility
    if (results.present? && in_ignore_accessibility_check != '1') || errors.present?
      self.accessibility_check_results = results
      errors.add(:base, 'アクセシビリティチェック結果を確認してください。')
    end
  end

  def body_limit_for_mobile
    limit = Zomeki.config.application['gp_article.body_limit_for_mobile'].to_i
    current_size = self.body_for_mobile.bytesize
    if current_size > limit
      target = self.mobile_body.present? ? :mobile_body : :body
      errors.add(target, "が携帯向け容量制限#{limit}バイトを超えています。（現在#{current_size}バイト）")
    end
  end

  def replace_public
    return if !state_public? || prev_edition.nil? || prev_edition.state_archived?

    prev_edition.update_column(:state, 'archived')
    self.comments = prev_edition.comments

    if (pe = prev_editions).size > 4 # Include self
      pe.last.destroy
    end
  end

  def keep_edition_relation
    next_edition.update_column(:prev_edition_id, prev_edition_id) if next_edition
    return true
  end
end
