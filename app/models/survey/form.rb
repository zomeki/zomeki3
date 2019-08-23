class Survey::Form < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::EditableGroup
  include Sys::Model::Rel::Task
  include Cms::Model::Base::Sitemap
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content
  include Sys::Model::Auth::EditableGroup

  include Approval::Model::Rel::Approval

  default_scope { order(:sort_no, :id) }

  column_attribute :summary, html: true
  column_attribute :description, html: true
  column_attribute :receipt, html: true
  column_attribute :sort_no, default: 10

  enum_ish :state, [:draft, :approvable, :approved, :prepared, :public, :closed], predicate: true
  enum_ish :confirmation, [true, false], default: true
  enum_ish :index_link, [:visible, :hidden], default: :visible
  enum_ish :mail_attachment, [true, false], default: false

  # Content
  belongs_to :content, class_name: 'Survey::Content::Form', required: true

  has_many :operation_logs, -> { where(item_model: 'Survey::Form') },
                            foreign_key: :item_id, class_name: 'Sys::OperationLog'

  has_many :questions, dependent: :destroy
  has_many :form_answers, dependent: :destroy
  has_many :answers, through: :form_answers

  validates :state, presence: true
  validates :name, presence: true, uniqueness: { scope: :content_id }, format: { with: /\A[-\w]*\z/ }
  validates :title, presence: true
  validates :mail_to, format: { with: /\A.+@.+\z/ }, if: -> { mail_to.present? }

  validates_with Sys::TaskValidator, if: -> { !state_draft? }

  after_save     Cms::Publisher::ContentCallbacks.new(belonged: true), if: :saved_changes?
  before_destroy Cms::Publisher::ContentCallbacks.new(belonged: true), prepend: true

  scope :public_state, -> { where(state: 'public') }

  def public_uri
    return unless node = content.node
    "#{node.public_uri}#{name}/"
  end

  def preview_uri(terminal: nil, params: {})
    return unless uri = public_uri
    flag = { mobile: 'm', smart_phone: 's' }[terminal]
    query = "?#{params.to_query}" if params.present?
    "/_preview/#{format('%04d', site.id)}#{flag}#{uri}#{query}"
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
    self.state = 'public'
    save(validate: false)
  end

  def close
    return unless state_public?
    self.state = 'closed'
    save(validate: false)
  end

  def index_visible?
    self.index_link != 'hidden'
  end
end
