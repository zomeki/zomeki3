class GpArticle::Content::Setting < Cms::ContentSetting
  # menu: :form
  set_config :lang, menu: :form,
    name: '言語選択',
    style: 'width: 500px;',
    comment: '例: 日本語 ja,英語 en,中国語（簡体） zh-CN,中国語（繁体） zh-tw,韓国語 ko',
    default_value: '日本語 ja,英語 en,中国語（簡体） zh-CN,中国語（繁体） zh-tw,韓国語 ko'
  set_config :allowed_attachment_type, menu: :form,
    name: '添付ファイル/許可する種類',
    style: 'width: 500px;',
    comment: '例: gif,jpg,png,pdf,doc,docx,xls,xlsx,ppt,pptx,odt,ods,odp',
    default_value: 'gif,jpg,png,pdf,doc,docx,xls,xlsx,ppt,pptx,odt,ods,odp'
  set_config :attachment_thumbnail_size, menu: :form,
    name: "添付ファイル/サムネイルサイズ",
    style: 'width: 100px;',
    comment: '例: 120x90',
    default_value: '120x90'
  set_config :feature_settings, menu: :form,
    name: '記事一覧表示',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    default_value: 'enabled',
    default_extra_values: { feature_1: 'true' }
  set_config :save_button_states, menu: :form,
    name: '即時公開ボタン',
    form_type: :check_boxes,
    options: GpArticle::Doc::STATE_OPTIONS.reject { |o| o.last != 'public' },
    default_value: ['public']
  set_config :inquiry_setting, menu: :form,
    name: '連絡先',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    extra_options: {
      default_state_options: [['表示', 'visible'], ['非表示', 'hidden']],
      display_field_options: [['住所', 'address'], ['TEL', 'tel'], ['FAX', 'fax'], ['メールアドレス', 'email'], ['備考', 'note']] # ['課', 'group_id'], ['室・担当', 'charge'],
    },
    default_value: 'enabled',
    default_extra_values: {
      display_fields: ['group_id', 'address', 'tel', 'fax', 'email', 'note']
    }
  set_config :blog_functions, menu: :form,
    name: 'ブログ',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    default_value: 'disabled',
    default_extra_values: {
      footer_style: '投稿者：@user@ @publish_time@ コメント(@comment_count@) カテゴリ：@category_link@',
      comment: 'disabled',
      comment_open: 'immediate',
      comment_notification_mail: 'disabled'
    }
  set_config :word_dictionary, menu: :form,
    name: "本文/単語変換辞書",
    form_type: :text,
    lower_text: "CSV形式（例　対象文字,変換後文字 ）"

  # menu: :index
  set_config :doc_list_lang, menu: :index,
    name: "言語設定",
    options: [['日本語', 'ja'], ['英語', 'en']],
    default_value: 'ja'
  set_config :doc_list_style, menu: :index,
    name: "#{GpArticle::Doc.model_name.human}一覧表示形式",
    options: [['日付毎', 'by_date'], ['記事一覧', 'simple']],
    default_value: 'by_date'
  set_config :list_style, menu: :index,
    name: "#{GpArticle::Doc.model_name.human}タイトル表示形式",
    form_type: :text_area,
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>',
    extra_options: {
      wrapper_tag_options: [['li', 'li'], ['article', 'article']]
    },
    default_value: '@title_link@(@publish_date@ @group@)',
    default_extra_values: { wrapper_tag: 'li' }
  set_config :date_style, menu: :index,
    name: "#{GpArticle::Doc.model_name.human}日時形式",
    comment: I18n.t('comments.date_style').html_safe,
    default_value: '%Y年%m月%d日'
  set_config :time_style, menu: :index,
    name: "#{GpArticle::Doc.model_name.human}時刻形式",
    comment: I18n.t('comments.time_style').html_safe,
    default_value: '%H時%M分'
  set_config :feed, menu: :index,
    name: "フィード",
    form_type: :radio_buttons,
    options: [['表示する', 'enabled'], ['表示しない', 'disabled']],
    default_value: 'disabled',
    default_extra_values: { feed_docs_number: '10' }

  # menu: :page
  set_config :basic_setting, menu: :page,
    name: 'レイアウト設定',
    options: lambda { Core.site.public_concepts_for_option.to_a },
    lower_text: "未設定の場合、記事ディレクトリの設定が記事へ反映されます"
  set_config :serial_no_settings, menu: :page,
    name: '記事番号表示',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    default_value: 'disabled'
  set_config :display_dates, menu: :page,
    name: '記事日時表示',
    options: [['公開日', 'published_at'], ['最終更新日', 'updated_at']],
    form_type: :check_boxes,
    default_value: ['published_at', 'updated_at']
  set_config :rel_docs_style, menu: :page,
    name: "関連#{GpArticle::Doc.model_name.human}タイトル表示形式",
    form_type: :text_area,
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>',
    default_value: '@title_link@(@publish_date@ @group@)'
  set_config :qrcode_settings, menu: :page,
    name: 'QRコード',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    extra_options: {
      default_state_options: [['表示', 'visible'], ['非表示', 'hidden']]
    },
    default_value: 'disabled',
    default_extra_values: { state: 'hidden' }

  # menu: :manage
  set_config :broken_link_notification, menu: :manage,
    name: 'リンク切れ通知',
    form_type: :radio_buttons,
    options: [['通知する', 'enabled'], ['通知しない', 'disabled']],
    default_value: 'disabled'

  # menu: :relation
  set_config :gp_category_content_category_type_id, menu: :relation,
    name: 'カテゴリ',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map { |ct| [ct.name, ct.id] } }
  set_config :map_relation, menu: :relation,
    name: '地図',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    default_value: 'enabled'
  set_config :tag_relation, menu: :relation,
    name: '関連ワード',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    default_value: 'enabled'
  set_config :approval_relation, menu: :relation,
    name: '承認フロー',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    default_value: 'enabled'
  set_config :calendar_relation, menu: :relation,
    name: 'カレンダー',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    extra_options: {
      event_sync_settings_options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
      event_sync_default_will_sync_options: [['同期する', 'enabled'], ['同期しない', 'disabled']]
    },
    default_value: 'enabled'
  set_config :organization_content_group_id, menu: :relation,
    name: '組織',
    options: lambda { Organization::Content::Group.where(site_id: Core.site.id).map { |g| [g.name, g.id] } }
  set_config :gp_template_content_template_id, menu: :relation,
    name: 'テンプレート',
    options: lambda { GpTemplate::Content::Template.where(site_id: Core.site.id).map { |t| [t.name, t.id] } }
  set_config :sns_share_relation, menu: :relation,
    name: 'SNSシェア',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    default_value: 'enabled'

  belongs_to :content, foreign_key: :content_id, class_name: 'GpArticle::Content::Doc'

  after_update :update_docs_event_state, if: -> { name == 'calendar_relation' }
  after_update :update_docs_marker_state, if: -> { name == 'map_relation' }

  def extra_values=(params)
    ex = extra_values
    case name
    when 'gp_category_content_category_type_id'
      ex[:category_type_ids] = (params[:category_types] || []).map {|ct| ct.to_i }
      ex[:visible_category_type_ids] = (params[:visible_category_types] || []).map {|ct| ct.to_i }
      ex[:default_category_type_id] = params[:default_category_type].to_i
      ex[:default_category_id] = params[:default_category].to_i
    when 'basic_setting'
      ex[:default_layout_id] = params[:default_layout_id].to_i
    when 'calendar_relation'
      ex[:calendar_content_id] = params[:calendar_content_id].to_i
      ex[:event_sync_settings] = params[:event_sync_settings].to_s
      ex[:event_sync_default_will_sync] = params[:event_sync_default_will_sync].to_s
    when 'map_relation'
      ex[:map_content_id] = params[:map_content_id].to_i
      ex[:lat_lng] = params[:lat_lng]
      ex[:marker_icon_category] = params[:marker_icon_category]
    when 'inquiry_setting'
      ex[:state] = params[:state]
      ex[:display_fields] = params[:display_fields] || []
    when 'approval_relation'
      ex[:approval_content_id] = params[:approval_content_id].to_i
    when 'gp_template_content_template_id'
      ex[:template_ids] = params[:template_ids].to_a.map(&:to_i)
      ex[:default_template_id] = params[:default_template_id].to_i
    when 'feed'
      ex[:feed_docs_number] = params[:feed_docs_number]
      ex[:feed_docs_period] = params[:feed_docs_period]
    when 'tag_relation'
      ex[:tag_content_tag_id] = params[:tag_content_tag_id].to_i
    when 'sns_share_relation'
      ex[:sns_share_content_id] = params[:sns_share_content_id].to_i
    when 'blog_functions'
      ex[:comment] = params[:comment]
      ex[:comment_open] = params[:comment_open]
      ex[:comment_notification_mail] = params[:comment_notification_mail]
      ex[:footer_style] = params[:footer_style]
    when 'feature_settings'
      ex[:feature_1] = params[:feature_1]
      ex[:feature_2] = params[:feature_2]
    when 'list_style'
      ex[:wrapper_tag] = params[:wrapper_tag]
    when 'qrcode_settings'
      ex[:state] = params[:state]
    when 'serial_no_settings'
      ex[:title] = params[:title]
    end
    super(ex)
  end

  def organization_content_group
    Organization::Content::Group.find_by(id: value)
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

  def default_layout_id
    extra_values[:default_layout_id] || 0
  end

  private

  def update_docs_event_state
    if content.gp_calendar_content_event.nil?
      content.docs.where(event_state: 'visible').update_all(event_state: 'hidden')
    end
  end

  def update_docs_marker_state
    if content.map_content_marker.nil?
      content.docs.where(marker_state: 'visible').update_all(marker_state: 'hidden')
    end
  end
end
