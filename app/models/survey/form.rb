class Survey::Form < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Task
  include Cms::Model::Auth::Concept

  include Approval::Model::Rel::Approval

  include StateText
  include Cms::Base::PublishQueue::Content

  STATE_OPTIONS = [['下書き保存', 'draft'], ['承認依頼', 'approvable'], ['即時公開', 'public']]
  CONFIRMATION_OPTIONS = [['あり', true], ['なし', false]]
  SITEMAP_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  INDEX_LINK_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]

  default_scope { order("#{self.table_name}.sort_no IS NULL, #{self.table_name}.sort_no") }

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Survey::Content::Form'
  validates :content_id, presence: true

  has_many :operation_logs, -> { where(item_model: 'Survey::Form') },
    foreign_key: :item_id, class_name: 'Sys::OperationLog'

  has_many :questions, :dependent => :destroy
  has_many :form_answers, :dependent => :destroy

  validates :state, presence: true
  validates :name, presence: true, uniqueness: { scope: :content_id }, format: { with: /\A[-\w]*\z/ }
  validates :title, presence: true

  after_initialize :set_defaults

  scope :public_state, -> { where(state: 'public') }

  def self.all_with_content_and_criteria(content, criteria)
    forms = self.arel_table

    rel = self.where(forms[:content_id].eq(content.id))
    rel = rel.where(forms[:state].eq(criteria[:state])) if criteria[:state].present?

    if criteria[:touched_user_id].present? || criteria[:editable].present?
      creators = Sys::Creator.arel_table
      rel = rel.joins(:creator)
    end

    if criteria[:touched_user_id].present?
      operation_logs = Sys::OperationLog.arel_table
      rel = rel.eager_load(:operation_logs).where(operation_logs[:user_id].eq(criteria[:touched_user_id])
                                                .or(creators[:user_id].eq(criteria[:touched_user_id])))
    end

    if criteria[:approvable].present?
      approval_requests = Approval::ApprovalRequest.arel_table
      assignments = Approval::Assignment.arel_table
      rel = rel.joins(:approval_requests => [:approval_flow => [:approvals => :assignments]])
               .where(approval_requests[:user_id].eq(Core.user.id)
                      .or(assignments[:user_id].eq(Core.user.id))).distinct
    end

    return rel
  end

  def public_questions
    questions.public_state
  end

  def automatic_reply?
    return true if automatic_reply_question
    false
  end

  def automatic_reply_question
    public_questions.each do |q|
      return q if q.email_field?
    end
    return nil
  end

  def open?
    now = Time.now
    return false if opened_at && opened_at > now
    return false if closed_at && closed_at < now
    return true
  end

  def state_options
    options = STATE_OPTIONS.clone
    options.reject!{|o| o.last == 'public' } unless Core.user.has_auth?(:manager)
    options.reject!{|o| o.last == 'approvable' } unless content.approval_related?
    return options
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

  def state_public?
    state == 'public'
  end

  def duplicate
    item = self.class.new(self.attributes)
    item.id            = nil
    item.created_at    = nil
    item.updated_at    = nil

    item.name  = nil
    item.title = item.title.gsub(/^(【複製】)*/, "【複製】")
    item.state = "draft"

    return false unless item.save(:validate => false)

    # piece_settings
    questions.each do |question|
      dupe_question = Survey::Question.new(question.attributes)
      dupe_question.form_id   = item.id
      dupe_question.created_at = nil
      dupe_question.updated_at = nil
      dupe_question.save(:validate => false)
    end

    return item
  end

  def publish
    return unless state_approved?
    approval_requests.destroy_all
    update_column(:state, 'public')
  end

  def close
    return unless state_public?
    update_column(:state, 'closed')
  end

  def public_uri
    return nil unless content.public_node
    "#{content.public_node.public_uri}#{name}"
  end

  def preview_uri(site: nil, mobile: false, params: {})
    return nil unless public_uri
    site ||= ::Page.site
    params = params.map{|k, v| "#{k}=#{v}" }.join('&')
    path = "_preview/#{format('%04d', site.id)}#{mobile ? 'm' : ''}#{public_uri}#{params.present? ? "?#{params}" : ''}"

    d = Cms::SiteSetting::AdminProtocol.core_domain site, :freeze_protocol => true
    "#{d}#{path}"
  end

  def sitemap_visible?
    self.sitemap_state == 'visible'
  end

  def index_visible?
    self.index_link != 'hidden'
  end

  private

  def set_defaults
    self.state        = STATE_OPTIONS.first.last        if self.has_attribute?(:state) && self.state.nil?
    self.confirmation = CONFIRMATION_OPTIONS.first.last if self.has_attribute?(:confirmation) && self.confirmation.nil?
    self.sitemap_state = SITEMAP_STATE_OPTIONS.first.last if self.has_attribute?(:sitemap_state) && self.sitemap_state.nil?
    self.index_link   = INDEX_LINK_OPTIONS.first.last   if self.has_attribute?(:index_link) && self.index_link.nil?
    self.sort_no      = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end
end
