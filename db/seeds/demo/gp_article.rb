## ---------------------------------------------------------
## cms/concepts

c_site  = @site.concepts.where(parent_id: 0).first
c_top   = @site.concepts.where(name: 'トップページ').first
c_content = @site.concepts.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
create_cms_content c_site, 'GpArticle::Doc', 'ぞめき市からのお知らせ', 'docs'
create_cms_content c_site, 'GpArticle::Doc', 'よくある質問', 'faq'

oshirase  = GpArticle::Content::Doc.where(concept_id: c_site.id, code: 'docs').first
shitsumon = GpArticle::Content::Doc.where(concept_id: c_site.id, code: 'faq').first

l_doc = Cms::Layout.where(site_id: @site.id, name: 'doc').first

create_cms_node c_site, oshirase, 30, nil, l_doc, 'GpArticle::Doc', oshirase.code, oshirase.name, nil
create_cms_node c_site, shitsumon, 40, nil, l_doc, 'GpArticle::Doc', shitsumon.code, shitsumon.name, nil

category = GpCategory::Content::CategoryType.where(concept_id: c_content.id).first
categories = GpCategory::CategoryType.where(content_id: category.id).pluck(:id)

kubun     = GpCategory::CategoryType.where(content_id: category.id, name: 'kubun').first
chumoku   = GpCategory::Category.where(category_type_id: categories, name: 'chumoku').first


tag       = Tag::Content::Tag.first
calendar  = GpCalendar::Content::Event.first
approval  = Approval::Content::ApprovalFlow.first
soshiki   = Organization::Content::Group.first
map       = Map::Content::Marker.first
template  = GpTemplate::Content::Template.first

## ---------------------------------------------------------
## cms/pieces
recent     = create_cms_piece c_top, oshirase, 'GpArticle::RecentTab', 'recent-docs-tab', '新着タブ'
recent.in_settings = {list_count: 10, date_style: '%Y年%m月%d日', list_style: '@title_link@@publish_date@@group@'}
recent.save

smartphone = create_cms_piece c_top, oshirase, 'GpArticle::RecentTab', 'smart-recent-docs-tab', '【スマートフォン】新着タブ'
smartphone.in_settings = {list_count: 5, date_style: '%Y年%m月%d日',
  list_style: '@title_link@@publish_date@@group@', more_link_body: '一覧へ'}
smartphone.save

mobile     = create_cms_piece c_top, oshirase, 'GpArticle::Doc', 'mobile-recent-docs', '【携帯】新着情報'
mobile.in_settings = {list_count: 5, doc_order: 'published_at_desc',
  date_style: '%Y年%m月%d日', list_style: '@title_link@', more_link_body: '一覧へ', more_link_url: '/docs/'}
mobile.save

create_cms_piece c_top,  category, 'GpCategory::Doc', 'attention-information', '注目情報', '注目情報'

p_info = GpCategory::Piece::Doc.where(site_id: @site.id, name: 'attention-information').first
category_sets = []
category_set = p_info.new_category_set
category_set[:category_type_id] = kubun.id
category_set[:category_id] = chumoku.id
category_set[:layer] = 'descendants'

category_sets << category_set

p_info.in_settings = {list_count: '5', docs_order: 'published_at_desc', page_filter: 'filter',
  doc_style: '@title_link@', data_style: '@@title_link@@', more_link_body: '一覧へ',
  more_link_url: '/categories/kubun/chumoku', category_sets: YAML.dump(category_sets),
  date_style: '%Y年%m月%d日 %H時%M分', gp_article_content_doc_ids: YAML.dump([oshirase.id])}
p_info.save


## ---------------------------------------------------------
## cms/content_settings

[
  {id: "feature_settings", value: "enabled",
      extra_values: {feature_1: true, feature_2: nil}},
  {id: "gp_category_content_category_type_id", value: category.id,
    extra_values: {category_types: categories,
    visible_category_types: categories, default_category_type_id: 0,
    default_category_id: 0}
    },
  {id: "lang", value: "日本語 ja,英語 en,中国語（簡体） zh-CN,中国語（繁体） zh-tw,韓国語 ko"},
  {id: "inquiry_setting", value: "enabled",
      extra_values: {state: 'visible',
      display_fields: ['address', 'tel', 'fax', 'email', 'note']}},
  {id: "list_style", value: "@title_link@@publish_date@@group@",
    extra_values: {wrapper_tag: "li"}},
  {id: "time_style", value: "%H時%M分"},
  {id: "map_relation", value: "enabled",
    extra_values: {map_content_id: map.id}},
  {id: "feed", value: "enabled"},
  {id: "blog_functions", value: "disabled"},
  {id: "broken_link_notification", value: "enabled"},
  {id: "tag_relation", value: "enabled",
    extra_values: {tag_content_tag_id: tag.id}},
  {id: "organization_content_group_id", value: soshiki.id},
  {id: "gp_template_content_template_id", value: template.id,
    extra_values: {template_ids: template.templates.pluck(:id), default_template_id: 0}},
  {id: "calendar_relation", value: "enabled",
    extra_values: {calendar_content_id: calendar.id, event_sync_settings: 'disabled',
    event_sync_default_will_sync: 'disabled'}},
  {id: "approval_relation", value: "enabled",
    extra_values: {approval_content_id: approval.id}},
  {id: "date_style", value: "%Y年%m月%d日"},
  {id: "display_dates", value: ['published_at', 'updated_at']},
  {id: "doc_list_style", value: "by_date"}
].each do |conf|
  item = GpArticle::Content::Setting.config(oshirase, conf[:id])
  item.value = conf[:value]
  item.extra_values = conf[:extra_values] if conf[:extra_values]
  item.save
end

[
  {id: "lang", value: "日本語 ja,英語 en,中国語（簡体） zh-CN,中国語（繁体） zh-tw,韓国語 ko"},
  {id: "allowed_attachment_type", value: "gif,jpg,png,pdf,doc,docx,xls,xlsx,ppt,pptx,odt,ods,odp"},
  {id: "attachment_thumbnail_size", value: "120x90"},
  {id: "feature_settings", value: "enabled",
    extra_values: {feature_1: true, feature_2: nil}},
  {id: "save_button_states", value: ['public']},
    {id: "inquiry_setting", value: "enabled",
      extra_values: {state: 'visible',
      display_fields: ['address', 'tel', 'fax', 'email', 'note']}},
  {id: "blog_functions", value: "disabled",
    extra_values: {footer_style: '投稿者：@user@ @publish_time@ コメント(@comment_count@) カテゴリ：@category_link@',
      comment: 'disabled', comment_open: 'immediate', comment_notification_mail: 'disabled'}},
  {id: "doc_list_style", value: "by_date"},
  {id: "date_style", value: "%Y年%m月%d日"},
  {id: "time_style", value: "%H時%M分"},
  {id: "feed", value: "disabled", extra_values: {feed_docs_number: 10}},
  {id: "serial_no_settings", value: "disabled"},
  {id: "display_dates", value: ['published_at', 'updated_at']},
  {id: "rel_docs_style", value: "@title_link@(@publish_date@ @group@)"},
  {id: "qrcode_settings", value: "disabled", extra_values: {state: 'hidden'}},
  {id: "broken_link_notification", value: "disabled"},
  {id: "map_relation", value: "disabled"},
  {id: "tag_relation", value: "enabled",
    extra_values: {tag_content_tag_id: tag.id}},
  {id: "approval_relation", value: "enabled",
    extra_values: {approval_content_id: approval.id}},
  {id: "calendar_relation", value: "disabled"},
  {id: "list_style", value: "@title_link@@publish_date@@group@",
    extra_values: {wrapper_tag: 'li'}},
].each do |conf|
  item = GpArticle::Content::Setting.config(shitsumon, conf[:id])
  item.value = conf[:value]
  item.extra_values = conf[:extra_values] if conf[:extra_values]
  item.save
end

def create(content, c_types, title, body, options = {})
  category_ids = {}
  if options[:categories] && c_types
    GpCategory::Category.where(category_type_id: c_types, name:  options[:categories]).each do |c|
      category_ids[c.category_type_id.to_s] = [] unless category_ids[c.category_type_id.to_s]
      category_ids[c.category_type_id.to_s] << c.id
    end
  end

  doc = content.docs.create title: title, body: body, mobile_body: body,
    in_category_ids: category_ids, state: 'public', raw_tags: options[:tags]
end

Core.user       = Sys::User.find_by(account: "#{@code_prefix}somu1")
Core.user_group = Core.user.groups[0]

GpArticle::Doc.skip_callback(:save, :after, :enqueue_publisher_callback)

create oshirase, categories, '転入届', read_data('gp_article/oshirase/tennyu/body'), {categories: ['juminhyo', 'hikkoshi']}
create oshirase, categories, '出生届', read_data('gp_article/oshirase/shussei/body'), {categories: ['ninshin', 'koseki']}
create oshirase, categories, '印鑑登録と印鑑登録証明書', read_data('gp_article/oshirase/inkan/body'), {categories: ['inkan']}
create oshirase, categories, '離婚届', read_data('gp_article/oshirase/rikon/body'), {categories: ['kekkon', 'koseki']}
create oshirase, categories, '死亡届', read_data('gp_article/oshirase/shibou/body'), {categories: ['koseki', 'shibo']}
create oshirase, categories, '転籍届', read_data('gp_article/oshirase/tenseki/body'), {categories: ['juminhyo', 'koseki']}
create oshirase, categories, '婚姻届', read_data('gp_article/oshirase/konin/body'), {categories: ['koseki', 'kekkon']}
create oshirase, categories, '外国人住民に関する登録の制度', read_data('gp_article/oshirase/touroku/body'), {categories: ['gaikokujin']}
create oshirase, categories, '手数料一覧', read_data('gp_article/oshirase/tesuryo/body'), {categories: ['shomei', 'hikkoshi']}
create oshirase, categories, '証明書一覧', read_data('gp_article/oshirase/syomeisyo/body'), {categories: ['shomei']}
create oshirase, categories, '申請書ダウンロード', read_data('gp_article/oshirase/shinseisyo/body'), {categories: ['shomei']}
create oshirase, categories, '住民票コード', read_data('gp_article/oshirase/juminhyo_code/body'), {categories: ['jukinet']}
create oshirase, categories, '住民基本台帳カード', read_data('gp_article/oshirase/daicho/body'), {categories: ['jukinet']}
create oshirase, categories, 'パスポートの申請・交付', read_data('gp_article/oshirase/passport/body'), {categories: ['passport']}
create oshirase, categories, '転出届', read_data('gp_article/oshirase/tensyutsu/body'), {categories: ['juminhyo']}
create oshirase, categories, '住民票のお知らせ', read_data('gp_article/oshirase/juminhyo/body'), {categories: ['juminhyo', 'chumoku']}
create oshirase, categories, '世帯主変更届', read_data('gp_article/oshirase/setainushi/body'), {categories: ['juminhyo']}
create oshirase, categories, '入札のお知らせ', read_data('gp_article/oshirase/nyusatsu/body'), {categories: ['joho', 'chumoku'], tags: '入札'}

create shitsumon, nil, 'ぞめき市外から転入したとき、住所変更の手続きはどうしたらよいですか', read_data('gp_article/shitsumon/body')

GpArticle::Doc.set_callback(:save, :after, :enqueue_publisher_callback)

