class GpArticle::Model::Criteria
  include ActiveModel::Model

  TARGET_OPTIONS = [['作成記事','user'], ['所属記事','group'], ['全所属','all']]
  TARGET_STATE_OPTIONS = [['公開前','processing'], ['公開中','public'], ['公開終了','closed'], ['全記事','all']]
  DATE_COLUMN_OPTIONS = [['作成','created_at'], ['承認','recognized_at'], ['公開','published_at']]
  DATE_OPERATION_OPTIONS = [['本日','today'],['今週','this_week'],['先週','last_week'],['指定日','equal'],['以前','before'],['以後','after'],['期間','between']]
  STATE_OPTIONS = [['下書き','draft'],['承認待ち','approvable'],['公開待ち','approved'],['公開日時待ち','prepared'],['公開中','public'],['非公開','closed']]
  USER_OPERATION_OPTIONS = [['作成','create'], ['承認','approve'], ['公開','publish']]

  CHECK_BOX_OPTIONS = [
    [:texts,'概要','summary'], [:assocs,'添付ファイル','files'], [:marker_state,'地図','visible'], [:tasks,'公開開始日時','publish'],
    [:texts,'サブタイトル','subtitle'], [:texts,'関連ワード','raw_tags'], [:event_state,'イベント','visible'], [:tasks,'公開終了日時','close'],
    [:texts,'リンクURL','href'],[:assocs,'関連記事','related_docs'],[:texts,'携帯記事','mobile_body']
  ]

  attr_accessor :params
  attr_accessor :target, :target_state, :target_public
  attr_accessor :free_word
  attr_accessor :category_type_ids, :category_ids
  attr_accessor :date_column, :date_operation, :dates
  attr_accessor :state
  attr_accessor :user_operation, :user_group_id, :user_name
  attr_accessor :marker_state, :event_state, :texts, :assocs, :tasks

  def initialize(params = {})
    super

    self.params = params
    self.category_type_ids ||= []
    self.category_ids ||= []
    self.dates ||= []
    self.texts ||= []
    self.assocs ||= []

    self.category_type_ids = category_type_ids.reject(&:blank?)
    self.category_ids = category_ids.reject(&:blank?)
    self.dates = dates.map { |date| Date.parse(date) rescue nil }.compact
  end

  def target_text
    TARGET_OPTIONS.rassoc(target).try(:first)
  end

  def target_state_text
    if target_state
      TARGET_STATE_OPTIONS.rassoc(target_state).try(:first)
    elsif target_public
      '公開記事'
    end
  end

  def category_texts
    category_ids.map { |id| GpCategory::Category.find_by(id: id).try(:title) }.compact
  end

  def state_text
    STATE_OPTIONS.rassoc(state).try(:first)
  end

  def date_column_text
    DATE_COLUMN_OPTIONS.rassoc(date_column).try(:first)
  end

  def date_operation_text
    DATE_OPERATION_OPTIONS.rassoc(date_operation).try(:first)
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

  def user_operation_text
    USER_OPERATION_OPTIONS.rassoc(user_operation).try(:first)
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
    headers << "公開:#{target_state_text}" if target_state_text.present?
    headers << "キーワード:#{free_word}" if free_word.present?
    headers << "カテゴリ:#{category_texts.join(' ')}" if category_texts.present?
    headers << "日付:#{date_options_text}" if date_options_text.present?
    headers << "状態:#{state_text}" if state_text.present?
    headers << "ユーザー:#{user_options_text}" if user_options_text.present?
    headers << check_box_options_text if check_box_options_text.present?
    headers.join(' ')
  end
end
