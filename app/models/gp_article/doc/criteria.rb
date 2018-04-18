class GpArticle::Doc::Criteria
  include ActiveModel::Model
  extend EnumIsh

  CHECK_BOX_OPTIONS = [
    [:texts,'概要','summary'], [:assocs,'添付ファイル','files'], [:marker_state,'地図','visible'], [:tasks,'公開開始日時','publish'],
    [:texts,'サブタイトル','subtitle'], [:texts,'関連ワード','raw_tags'], [:event_state,'イベント','visible'], [:tasks,'公開終了日時','close'],
    [:texts,'リンクURL','href'],[:assocs,'関連記事','related_docs'],[:texts,'携帯記事','mobile_body']
  ]

  ATTRIBUTES = [
    :target, :target_state, :target_public,
    :serial_no, :free_word,
    :category_type_ids, :category_ids,
    :date_column, :date_operation, :dates,
    :state,
    :user_operation, :user_group_id, :user_name,
    :marker_state, :event_state, :texts, :assocs, :tasks
  ]

  attr_accessor(*ATTRIBUTES)

  enum_ish :target, [:user, :group, :all]
  enum_ish :target_state, [:processing, :public, :closed, :all, :trashed]
  enum_ish :date_column, [:created_at, :updated_at, :recognized_at, :published_at]
  enum_ish :date_operation, [:today, :this_week, :last_week, :equal, :before, :after, :between]
  enum_ish :state, [:draft, :approvable, :approved, :prepared, :public, :closed]
  enum_ish :user_operation, [:create, :approve, :publish]

  def initialize(params = {})
    params = params.slice(*ATTRIBUTES)
    super(params)

    self.category_type_ids ||= []
    self.category_ids ||= []
    self.dates ||= []
    self.texts ||= []
    self.assocs ||= []

    self.category_type_ids = category_type_ids.reject(&:blank?)
    self.category_ids = category_ids.reject(&:blank?)
    self.dates = dates.map { |date| Date.parse(date) rescue nil }.compact
  end

  def target_state_text_for_csv
    if target_state
      target_state_text
    elsif target_public
      '公開記事'
    end
  end

  def category_texts
    category_ids.map { |id| GpCategory::Category.find_by(id: id).try(:title) }.compact
  end

  def date_options_text
    strs = [
      date_column_text.presence,
      date_operation_text.presence
    ]
    dates.each do |date|
      strs << I18n.l(date)
    end
    strs.compact.join(' ')
  end

  def user_group_id_text
    Sys::Group.find_by(id: user_group_id).try(:name)
  end

  def user_options_text
    strs = [
      user_operation_text.presence,
      user_group_id_text.presence,
      user_name.presence
    ]
    strs.compact.join(' ')
  end

  def check_box_options_text
    strs = []
    CHECK_BOX_OPTIONS.each do |method, label, value|
      case method
      when :texts, :assocs, :tasks
        strs << "#{label}:有" if send(method).to_a.include?(value)
      else
        strs << "#{label}:有" if send(method) == value
      end
    end
    strs.compact.join(' ')
  end

  def to_csv_string
    headers = []
    headers << "所属:#{target_text}" if target_text.present?
    headers << "公開:#{target_state_text_for_csv}" if target_state_text_for_csv.present?
    headers << "記事番号:#{serial_no}" if serial_no.present?
    headers << "キーワード:#{free_word}" if free_word.present?
    headers << "カテゴリ:#{category_texts.join(' ')}" if category_texts.present?
    headers << "日付:#{date_options_text}" if date_options_text.present?
    headers << "状態:#{state_text}" if state_text.present?
    headers << "ユーザー:#{user_options_text}" if user_options_text.present?
    headers << check_box_options_text if check_box_options_text.present?
    headers.join(' ')
  end
end
