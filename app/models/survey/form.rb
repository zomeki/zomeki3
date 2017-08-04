class Survey::Form < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::EditableGroup
  include Sys::Model::Rel::Task
  include Cms::Model::Site
  include Cms::Model::Base::Sitemap
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content
  include Sys::Model::Auth::EditableGroup

  include Approval::Model::Rel::Approval

  include StateText

  CONFIRMATION_OPTIONS = [['あり', true], ['なし', false]]
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
  validates :mail_to, format: { with: /\A.+@.+\z/ }, if: -> { mail_to.present? }

  after_initialize :set_defaults

  after_save     Cms::Publisher::ContentCallbacks.new(belonged: true), if: :changed?
  before_destroy Cms::Publisher::ContentCallbacks.new(belonged: true)

  scope :public_state, -> { where(state: 'public') }

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

  def duplicate
    item = self.class.new(self.attributes)
    item.id            = nil
    item.created_at    = nil
    item.updated_at    = nil

    item.name  = nil
    item.title = item.title.gsub(/^(【複製】)*/, "【複製】")
    item.state = "draft"

    return false unless item.save(validate: false)

    questions.each do |question|
      dupe_question = Survey::Question.new(question.attributes.except('id'))
      dupe_question.form_id = item.id
      dupe_question.created_at = nil
      dupe_question.updated_at = nil
      dupe_question.save(validate: false)
    end

    return item
  end

  def publishable?
    (state_approved? || state_prepared?) && (editable? || approval_participators.include?(Core.user))
  end

  def closable?
    state_public? && editable?
  end

  def publish
    return if !state_approved? && !state_prepared?
    update_attributes(state: 'public')
  end

  def close
    return unless state_public?
    update_attributes(state: 'closed')
  end

  def public_uri(with_closed_preview: false)
    node = if with_closed_preview
             content.form_node
           else
             content.public_node
           end
    return nil unless node
    "#{node.public_uri}#{name}"
  end

  def preview_uri(terminal: nil, params: {})
    return if (path = public_uri(with_closed_preview: true)).blank?
    flag = { mobile: 'm', smart_phone: 's' }[terminal]
    query = "?#{params.to_query}" if params.present?
    "#{site.main_admin_uri}_preview/#{format('%04d', site.id)}#{flag}#{path}#{query}"
  end

  def index_visible?
    self.index_link != 'hidden'
  end

  private

  def set_defaults
    self.confirmation = CONFIRMATION_OPTIONS.first.last if self.has_attribute?(:confirmation) && self.confirmation.nil?
    self.index_link   = INDEX_LINK_OPTIONS.first.last   if self.has_attribute?(:index_link) && self.index_link.nil?
    self.sort_no      = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end
end
