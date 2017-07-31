class Survey::Content::Form < Cms::Content
  default_scope { where(model: 'Survey::Form') }

  FORM_STATE_OPTIONS = [['下書き保存', 'draft'], ['承認依頼', 'approvable'], ['即時公開', 'public']]

  has_one :public_node, -> { public_state.where(model: 'Survey::Form').order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :form_node, -> { where(model: 'Survey::Form').order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'Survey::Content::Setting', dependent: :destroy

  has_many :forms, foreign_key: :content_id, class_name: 'Survey::Form', dependent: :destroy

  def public_forms
    forms.public_state
  end

  def mail_from
    setting_value(:mail_from).to_s
  end

  def mail_to
    setting_value(:mail_to).to_s
  end

  def upper_reply_text
    setting_extra_values(:auto_reply)[:upper_reply_text].to_s rescue nil
  end

  def lower_reply_text
    setting_extra_values(:auto_reply)[:lower_reply_text].to_s rescue nil
  end

  def approval_content_approval_flow
    Approval::Content::ApprovalFlow.find_by(id: setting_extra_value(:approval_relation, :approval_content_id))
  end

  def approval_related?
    setting_value(:approval_relation) == 'enabled'
  end

  def publish_after_approved?
    setting_extra_value(:approval_relation, :publish_after_approved) == 'enabled'
  end

  def use_captcha?
    setting_value(:captcha) == 'enabled'
  end

  def auto_reply?
    setting_value(:auto_reply) == 'send'
  end

  def use_common_ssl?
    setting_value(:common_ssl) == 'enabled'
  end

  def form_state_options(user = Core.user)
    options = FORM_STATE_OPTIONS.clone
    options.reject! { |o| o.last == 'public' } unless user.has_auth?(:manager)
    options.reject! { |o| o.last == 'approvable' } unless approval_related?
    options
  end
end
