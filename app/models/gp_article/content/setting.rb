class GpArticle::Content::Setting < Cms::ContentSetting
  # menu: :form
  set_config :lang, menu: :form,
    name: '言語選択',
    comment: "例: 日本語 ja,英語 en"
  set_config :allowed_attachment_type, menu: :form,
    name: '添付ファイル/許可する種類',
    comment: '（例 gif,jpg,png,pdf,doc,xls,ppt,odt,ods,odp ）'
  set_config :attachment_thumbnail_size, menu: :form,
    name: "添付ファイル/サムネイルサイズ",
    comment: "（例 120x90 ）",
    style: 'width: 100px;'
  set_config :feature_settings, menu: :form,
    name: '記事一覧表示',
    options: GpArticle::Content::Doc::FEATURE_SETTINGS_OPTIONS,
    form_type: :radio_buttons
  set_config :save_button_states, menu: :form,
    name: '即時公開ボタン',
    options: GpArticle::Doc::STATE_OPTIONS.reject { |o| o.last != 'public' },
    form_type: :check_boxes
  set_config :inquiry_setting, menu: :form,
    name: '連絡先',
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    form_type: :radio_buttons
  set_config :blog_functions, menu: :form,
    name: 'ブログ',
    options: GpArticle::Content::Doc::BLOG_FUNCTIONS_OPTIONS,
    form_type: :radio_buttons
  set_config :word_dictionary, menu: :form,
    name: "本文/単語変換辞書",
    form_type: :text, lower_text: "CSV形式（例　対象文字,変換後文字 ）"

  # menu: :index
  set_config :doc_list_style, menu: :index,
    name: "#{GpArticle::Doc.model_name.human}一覧表示形式",
    options: GpArticle::Content::Doc::DOC_LIST_STYLE_OPTIONS
  set_config :list_style, menu: :index,
    name: "#{GpArticle::Doc.model_name.human}タイトル表示形式",
    form_type: :text_area, upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>'
  set_config :date_style, menu: :index,
    name: "#{GpArticle::Doc.model_name.human}日時形式",
    comment: I18n.t('comments.date_style').html_safe
  set_config :time_style, menu: :index,
    name: "#{GpArticle::Doc.model_name.human}時刻形式",
    comment: I18n.t('comments.time_style').html_safe
  set_config :feed, menu: :index,
    name: "フィード",
    options: GpArticle::Content::Doc::FEED_DISPLAY_OPTIONS,
    form_type: :radio_buttons

  # menu: :page
  set_config :basic_setting, menu: :page,
    name: 'レイアウト設定',
    options: lambda { Core.site.public_concepts_for_option.to_a },
    lower_text: "未設定の場合、記事ディレクトリの設定が記事へ反映されます"
  set_config :serial_no_settings, menu: :page,
    name: '記事番号表示',
    options: GpArticle::Content::Doc::SERIALNO_SETTINGS_OPTIONS,
    form_type: :radio_buttons
  set_config :display_dates, menu: :page,
    name: '記事日時表示',
    options: [['公開日', 'published_at'], ['最終更新日', 'updated_at']],
    form_type: :check_boxes
  set_config :rel_docs_style, menu: :page,
    name: "関連#{GpArticle::Doc.model_name.human}タイトル表示形式",
    form_type: :text_area,
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>'
  set_config :qrcode_settings, menu: :page,
    name: 'QRコード',
    options: GpArticle::Content::Doc::QRCODE_SETTINGS_OPTIONS,
    form_type: :radio_buttons

  # menu: :manage
  set_config :broken_link_notification, menu: :manage,
    name: 'リンク切れ通知',
    options: GpArticle::Content::Doc::BROKEN_LINK_NOTIFICATION_OPTIONS,
    form_type: :radio_buttons

  # menu: :relation
  set_config :gp_category_content_category_type_id, menu: :relation,
    name: 'カテゴリ',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map { |ct| [ct.name, ct.id] } }
  set_config :map_relation, menu: :relation,
    name: '地図',
    options: GpArticle::Content::Doc::MAP_RELATION_OPTIONS,
    form_type: :radio_buttons
  set_config :tag_relation, menu: :relation,
    name: '関連ワード',
    options: GpArticle::Content::Doc::TAG_RELATION_OPTIONS,
    form_type: :radio_buttons
  set_config :approval_relation, menu: :relation,
    name: '承認フロー',
    options: GpArticle::Content::Doc::APPROVAL_RELATION_OPTIONS,
    form_type: :radio_buttons
  set_config :calendar_relation, menu: :relation,
    name: 'カレンダー',
    options: GpArticle::Content::Doc::CALENDAR_RELATION_OPTIONS,
    form_type: :radio_buttons
  set_config :organization_content_group_id, menu: :relation,
    name: '組織',
    options: lambda { Organization::Content::Group.where(site_id: Core.site.id).map { |g| [g.name, g.id] } }
  set_config :gp_template_content_template_id, menu: :relation,
    name: 'テンプレート',
    options: lambda { GpTemplate::Content::Template.where(site_id: Core.site.id).map { |t| [t.name, t.id] } }
  set_config :sns_share_relation, menu: :relation,
    name: 'SNSシェア',
    options: GpArticle::Content::Doc::SNS_SHARE_RELATION_OPTIONS,
    form_type: :radio_buttons

  DEFAULT_LANG = '日本語 ja,英語 en,中国語（簡体） zh-CN,中国語（繁体） zh-tw,韓国語 ko'

  after_initialize :set_defaults

  def organization_content_group
    Organization::Content::Group.find_by(id: value)
  end

  def content
    GpArticle::Content::Doc.find(content_id)
  end

  def category_type_ids
    extra_values[:category_type_ids] || []
  end

  def visible_category_type_ids
    extra_values[:visible_category_type_ids] || []
  end

  def default_category_type_id
    extra_values[:default_category_type_id] || 0
  end

  def default_category_id
    extra_values[:default_category_id] || 0
  end

  def default_layout_id
    extra_values[:default_layout_id] || 0
  end

  def template_ids
    extra_values[:template_ids] || []
  end

  def default_template_id
    extra_values[:default_template_id] || 0
  end

  def default_inquiry_setting
    {
      display_fields: ['group_id', 'address', 'tel', 'fax', 'email', 'note']
    }
  end

  def default_layout_id
    extra_values[:default_layout_id] || 0
  end

  private

  def set_defaults
    case name
    when 'inquiry_setting'
      self.value = 'enabled' if value.blank?
      self.extra_values = default_inquiry_setting if extra_values.blank?
    when 'feed'
      self.value = 'enabled' if value.blank?
      self.extra_values = { feed_docs_number: '10' } if extra_values.blank?
    when 'blog_functions'
      ev = self.extra_values
      ev[:footer_style] = '投稿者：@user@ @publish_time@ コメント(@comment_count@) カテゴリ：@category_link@' if ev[:footer_style].nil?
      self.extra_values = ev
    when 'qrcode_settings'
      self.value = 'disabled' if value.blank?
      self.extra_values = { state: 'hidden' } if extra_values.blank?
    when 'serial_no_settings'
      self.value = 'disabled' if value.blank?
    when 'lang'
      self.value = DEFAULT_LANG if self.value.blank?
    end
  end
end
