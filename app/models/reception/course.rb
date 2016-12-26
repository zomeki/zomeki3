class Reception::Course < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::File
  include Cms::Model::Auth::Content
  include GpCategory::Model::Rel::Category

  include StateText
  include Cms::Base::PublishQueue::Content

  STATE_OPTIONS = [['下書き','draft'],['公開中','public'],['非公開','closed']]

  # Content
  belongs_to :content, foreign_key: :content_id, class_name: 'Reception::Content::Course'

  has_many :opens, -> { order_by_open_at }, dependent: :destroy
  has_many :public_opens, -> { public_state.order_by_open_at }, class_name: 'Reception::Open'

  before_save :set_defaults
  after_save :set_name

  validates :title, presence: true
  validates :name, exclusion: { in: %w(categories) }

  scope :public_state, -> { where(state: 'public') }
  scope :with_target, ->(target) { target.present? ? where(state: target) : all }
  scope :search_with_criteria, ->(criteria) {
    rel = all
    rel = rel.where(:state => criteria[:state]) if criteria[:state].present?
    rel = rel.search_with_text(:title, :subtitle, :body, :remark, :description, criteria[:keyword]) if criteria[:keyword].present?
    rel
  }
  scope :has_public_opens, -> {
    distinct.joins(:opens)
            .where(state: 'public')
            .merge(Reception::Open.public_state)
  }
  scope :has_available_opens, -> {
    distinct.joins(:opens)
            .where(state: 'public')
            .merge(Reception::Open.available_period)
  }
  scope :categorized_into, ->(categories) {
    cats = GpCategory::Categorization.arel_table
    where(id: GpCategory::Categorization.select(:categorizable_id)
                                        .where(cats[:category_id].in(Array(categories).map(&:id))))
  }
  scope :order_by_min_open_at, ->(sort = 'asc') {
    sql = Reception::Open.select(%Q|MIN("reception_opens"."open_on" + "reception_opens"."start_at")|)
                         .where(%Q|"reception_courses"."id" = "reception_opens"."course_id"|).to_sql
    sort = sort.downcase == 'asc' ? 'ASC' : 'DESC'
    order("(#{sql}) #{sort}")
  }

  def applicants
    opens = Reception::Open.arel_table
    Reception::Applicant.joins(:open).where(opens[:course_id].eq(id))
  end

  def applicable_opens
    opens.joins(:course)
         .merge(Reception::Open.public_state)
         .merge(Reception::Open.available_period)
         .merge(Reception::Open.within_capacity)
  end

  def state_draft?
    state == 'draft'
  end

  def state_public?
    state == 'public'
  end

  def state_closed?
    state == 'closed'
  end

  def public_uri
    return nil unless content.public_node
    "#{content.public_node.public_uri}#{name}"
  end

  def public_full_uri
    return nil unless content.public_node
    "#{content.public_node.public_full_uri}#{name}"
  end

  def public_path
    return '' if public_uri.blank?
    "#{content.public_path}#{public_uri}/index.html"
  end

  def public_files_path
    "#{::File.dirname(public_path)}/file_contents"
  end

  def admin_uri
    "/_system/reception/c#{content.concept_id}/#{content.id}/courses/#{id}"
  end

  def bread_crumbs(node)
    crumbs = []

    if content.doc_list_style == 'all_categories'
      categories.public_state.each do |category|
        category_type = category.category_type
        if (node = content.public_node)
          crumb = node.bread_crumbs.crumbs.first
          category.ancestors.each {|a| crumb << [a.title, "#{node.public_uri}categories/#{category_type.name}/#{a.path_from_root_category}/"] }
          crumbs << crumb
        end
      end
    end

    if content
      if (node = content.public_node)
        crumb = node.bread_crumbs.crumbs.first
        crumb << [title, self.public_uri]
        crumbs << crumb
      end
    end

    if crumbs.empty?
      node.routes.each do |r|
        crumb = []
        r.each {|i| crumb << [i.title, i.public_uri] }
        crumbs << crumb
      end
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def applicable?
    opens.any?(&:applicable?)
  end

  private

  def set_defaults
    self.state ||= 'public'
  end

  def set_name
    update_column(:name, id) if name.blank?
  end

  concerning :File do
    included do
      before_save :make_file_path_relative
    end

    def make_file_path_relative
      [:body, :remark, :description].each do |column|
        text = read_attribute(column)
        if text.present?
          self[column] = text.gsub(%r|"/_system/sys/.+?/inline_files/\d+/(file_contents.+?)"|, %Q|"\\1"|)
        end
      end
    end

    def replace_file_path_for_admin(text)
      text.gsub(%r|"file_contents/(.+)"|, %Q|"#{admin_uri}/file_contents/\\1"|) if text.present?
    end

    def replace_file_path_for_public(text)
      text.gsub(%r|"file_contents/(.+)"|, %Q|"#{public_uri}/file_contents/\\1"|) if text.present?
    end
  end
end
