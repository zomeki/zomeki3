# encoding: utf-8

site_name = "ZOMEKI"

## ---------------------------------------------------------
## methods

def load_demo(name)
  puts "import #{name}..."
  load "#{Rails.root}/db/seed/demo/#{name}.rb"
end

def read_data(path)
  path = "#{Rails.root}/db/seed/demo/#{path}.txt"
  return nil unless FileTest.exists?(path)
  ::File.new(path).read.force_encoding('utf-8')
end

## ---------------------------------------------------------
## sys/groups

puts "import sys_users..."

def create(parent, level_no, sort_no, code, name, name_en)
  Sys::Group.create parent_id: (parent == 0 ? 0 : parent.id),
    level_no:  level_no,
    sort_no:   sort_no,
    state:     'enabled',
    web_state: 'closed',
    ldap:      0,
    code:      code,
    name:      name,
    name_en:   name_en,
    tel:       '0000-01-0000',
    fax:       '0000-01-0000',
    email:     'info@sitebridge.co.jp'
end

p = create r, 2, 10, "1", "総務部", "somu"
    create p, 3, 10, "1001", "職員課", "shokuin"
    create p, 3, 20, "1002", "契約管理課", "keiyakukanri"
    create p, 3, 30, "1003", "防災課", "bosai"
    create p, 3, 40, "1004", "法務課", "homu"

p = create r, 2, 20, "2", "企画部", "kikaku"
    create p, 3, 10, "2001", "IT推進課", "itsuishinka"
    create p, 3, 20, "2002", "企画経営課", "kikakukeiei"
    create p, 3, 30, "2003", "財政課", "zaisei"
    create p, 3, 40, "2004", "秘書広報課", "hishokoho"
    create p, 3, 50, "2005", "情報推進課", "johosuishin"

p = create r, 2, 30, "3", "生活部", "seikatsu"
    create p, 3, 10, "3001", "市民課", "shimin"
    create p, 3, 20, "3002", "税務課", "zeimu"
    create p, 3, 30, "3003", "保健課", "hoken"

p = create r, 2, 40, "4", "環境部", "kankyo"
    create p, 3, 10, "4001", "環境政策課", "kankyoseisaku"
    create p, 3, 20, "4002", "生活経済課", "seikatsukeizai"
    create p, 3, 30, "4003", "安全安心課", "anzenanshin"

p = create r, 2, 50, "5", "保健福祉部", "hokenfukushi"
    create p, 3, 10, "5001", "子育て支援課", "kosodateshien"
    create p, 3, 20, "5002", "地域福祉課", "chiikifukushi"
    create p, 3, 30, "5003", "高齢者支援課", "koreishashien"
    create p, 3, 40, "5004", "生活福祉課", "seikatsufukushika"
    create p, 3, 50, "5005", "健康推進課", "kenkosuishin"
    create p, 3, 60, "5006", "障害福祉課", "shogaifukushi"

p = create r, 2, 60, "6", "都市整備部", "toshiseibi"
    create p, 3, 10, "6001", "下水道課", "gesuido"
    create p, 3, 20, "6002", "土木課", "doboku"
    create p, 3, 30, "6003", "建築住宅課", "kenchikujyutaku"
    create p, 3, 40, "6004", "道路交通課", "dorokotsu"
    create p, 3, 50, "6005", "都市計画課", "toshikeikaku"

p = create r, 2, 70, "7", "観光経済部", "kankokeizai"
    create p, 3, 10, "7001", "商工課", "shoko"
    create p, 3, 20, "7002", "農林水産課", "norinsuisan"
    create p, 3, 30, "7003", "観光振興課", "kankoshinko"

p = create r, 2, 80, "8", "消防本部", "shobohonbu"
    create p, 3, 10, "8001", "消防本部総務課", "shobo-somu"
    create p, 3, 20, "8002", "予防課", "yobo"
    create p, 3, 30, "8003", "消防署", "shobosho"

p = create r, 2, 90, "9", "議会事務局", "gikaijimukyoku"

p = create r, 2, 100, "10", "選挙管理委員会事務局", "senkyokanriiinkaijimukyoku"

p = create r, 2, 110, "11", "監査委員事務局", "kansaiinjimukyoku"


## ---------------------------------------------------------
## current_user

Core.user       = Sys::User.find_by(account: 'zomeki')
Core.user_group = Core.user.groups[0]

## ---------------------------------------------------------
## cms/sites

Cms::Site.update_all({:name => site_name})


## ---------------------------------------------------------
## cms/concepts

puts "import cms_concepts..."

def create_cms_concept(parent_id, sort_no, name)
  Cms::Concept.create parent_id: parent_id,
    site_id: 1,
    state: 'public',
    level_no: level_no,
    name: name
end

c_site  = Cms::Concept.find(1)
c_site.name = 'ルート'
c_site.save

c_top      = create_cms_concept c_site, 10, 'トップページ'
c_contents = create_cms_concept c_top,   20, 'コンテンツ'

c_event    = create_cms_concept c_contents, 10, 'イベント'

c_event    = create_cms_concept c_event, 10, 'イベント一覧'
c_event    = create_cms_concept c_event, 20, 'カレンダー'

             create_cms_concept c_contents, 20, '施設案内'
c_gnavi    = create_cms_concept c_contents, 30, 'グローバルナビ'

c_gnavi1   = create_cms_concept c_gnavi, 10, '暮らしのガイド'
c_gnavi2   = create_cms_concept c_gnavi, 20, '子育て・教育'
c_gnavi3   = create_cms_concept c_gnavi, 30, '観光・文化'
c_gnavi4   = create_cms_concept c_gnavi, 40, '事業者の方へ'
c_gnavi5   = create_cms_concept c_gnavi, 50, '市政情報'

c_category = create_cms_concept c_contents, 40, 'カテゴリ'

             create_cms_concept c_category, 10, '区分'

c_bunya    = create_cms_concept c_category, 20, '分野'
             create_cms_concept c_bunya,    10,'届出・登録・証明'
             create_cms_concept c_bunya,    20,'保険・年金・介護'
             create_cms_concept c_bunya,    30,'福祉'
             create_cms_concept c_bunya,    40,'健康・予防'
             create_cms_concept c_bunya,    50,'税金'
             create_cms_concept c_bunya,    60,'育児・教育'
             create_cms_concept c_bunya,    70,'生活・インフラ'
             create_cms_concept c_bunya,    80,'安心・安全'
             create_cms_concept c_bunya,    90,'環境・ごみ'
             create_cms_concept c_bunya,    100,'入札・契約'
             create_cms_concept c_bunya,    110,'都市整備'
             create_cms_concept c_bunya,    120,'地域産業'
             create_cms_concept c_bunya,    130,'市政情報'
             create_cms_concept c_bunya,    140,'歴史・文化財'
             create_cms_concept c_bunya,    150,'施設案内'
             create_cms_concept c_bunya,    160,'市紹介'
             create_cms_concept c_bunya,    170,'議会・選挙'
             create_cms_concept c_bunya,    180,'広報・広聴'
             create_cms_concept c_bunya,    190,'情報公開'
             create_cms_concept c_bunya,    200,'交流事業'

             create_cms_concept c_category, 30, 'ライフイベント'
             create_cms_concept c_category, 40, 'イベント情報'

             create_cms_concept c_category, 50, '組織'

c_mayor    = create_cms_concept c_top,   30,'市長の部屋'
c_gikai    = create_cms_concept c_top,   40,'市議会'


## ---------------------------------------------------------
## cms/contents

puts "import cms_conctents..."

def create_cms_content(concpet, model, name)
  Cms::Content.create site_id: 1,
    concept_id: concept.id,
    state: 'public',
    model: model,
    name: name
end

## ---------------------------------------------------------
## cms/layouts

puts "import cms_layouts..."

def create_cms_layout(concept, name, title)
  Cms::Layout.create site_id: 1,
    concept_id: concept_id,
    state: 'public',
    head: read_data("layouts/#{name}/head"),
    body: read_data("layouts/#{name}/body"),
    mobile_head: read_data("layouts/#{name}/m_head"),
    mobile_body: read_data("layouts/#{name}/m_body"),
    smart_phone_head: read_data("layouts/#{name}/s_head"),
    smart_phone_body: read_data("layouts/#{name}/s_body"),
    name: name,
    title: title
end

l_top       = create_cms_layout c_top,  'top',     'トップ'
l_category  = create_cms_layout c_site, 'category','カテゴリ'
l_bunya     = create_cms_layout c_site, 'category-bunya', 'カテゴリ（分野）'
l_gnavi     = create_cms_layout c_site, 'global-navi',    'グローバルナビ'
l_event     = create_cms_layout c_site, 'event-calendar', 'イベント'
l_doc       = create_cms_layout c_site, 'doc',          '記事'
l_col1      = create_cms_layout c_site, 'col-1',        '固定ページ（1カラム）'
l_map       = create_cms_layout c_site, 'map',          'マップ一覧'
l_tag       = create_cms_layout c_site, 'tag',          '関連ワード'
l_top_grp   = create_cms_layout c_site, 'soshiki-top',  '組織TOP'
l_grouop    = create_cms_layout c_site, 'soshiki',      '組織'
l_mayor     = create_cms_layout c_mayor, 'mayor',        '市長の部屋'
l_gikai     = create_cms_layout c_gikai, 'gikai',        '市議会'
l_emergency = create_cms_layout c_top,  'emergency-top','大規模災害時表示（TOPページ）'

## ---------------------------------------------------------
## cms/pieces

puts "import cms_pieces..."

def create_cms_piece(concept, model, name, title)
  Cms::Piece.create site_id: 1,
    concept_id: concept.id,
    state: 'public',
    body: read_data("pieces/#{name}/body"),
    xml_properties: read_data("pieces/#{name}/xml_properties")
end

[
  [ c_site,   'Cms::Free', 'pc-switch', 'スマートフォン版切り替えボタン' ],
  [ c_site,   'Cms::Free', 'accessibility-tool', 'ふりがな・よみあげヘッダー' ],
  [ c_site,   'Cms::Free', 'common-header', '共通ヘッダー' ],
  [ c_site,   'Cms::Free', 'global-navi', 'グローバルナビ' ],
  [ c_top,    'Cms::Free', 'lifeevent', 'ライフイベント' ],
  [ c_top,    'Cms::Free', 'guide', '暮らしのガイド' ],
  [ c_top,    'Cms::Free', 'bn-mayor', '市長の部屋バナー' ],
  [ c_top,    'Cms::Free', 'bn-contets', '左サイドバナー（下部）' ],
  [ c_top,    'Cms::Free', 'bn-gikai', '議会バナー' ],
  [ c_top,    'Cms::Free', 'bn-contact', '市へのお問い合わせバナー' ],
  [ c_top,    'Cms::Free', 'bn-shisetsumap', '施設マップバナー' ],
  [ c_top,    'Cms::Free', 'kinkyu-list', 'もしものとき' ],
  [ c_site,   'Cms::Free', 'smart-switch', '【スマートフォン】PC切り替えボタン' ],
  [ c_site,   'Cms::BreadCrumb', 'bread-crumbs', 'パンくず' ],
  [ c_site,   'Cms::PageTitle', 'page-title', 'ページタイトル' ],
  [ c_top,    'Cms::Free', 'recently', 'ぞめき市の今' ],
  [ c_site,   'Cms::Free', 'smart-common-header', '【スマートフォン】共通ヘッダー' ],
  [ c_site,   'Cms::Free', 'copyright', 'コピーライト' ],
  [ c_site,   'Cms::Free', 'common-footer', '共通フッター' ],
  [ c_top,    'Cms::Free', 'smart-mayor', '【スマートフォン】市長の部屋' ],
  [ c_site,   'Cms::Free', 'smart-faq', '【スマートフォン】よくある質問' ],
  [ c_top,    'Cms::Free', 'smart-lifeevent', '【スマートフォン】ライフイベント' ],
  [ c_site,   'Cms::Free', 'smart-footer-navi', '【スマートフォン】フッターナビ' ],
  [ c_site,   'Cms::Free', 'footer-navi', 'フッターナビ' ],
  [ c_top,    'Cms::Free', 'smart-bn-lower', '【スマートフォン】左サイドバナー（下部）' ],
  [ c_site,   'Cms::Free', 'smart-common-footer', '【スマートフォン】共通フッター' ],
  [ c_top,    'Cms::Free', 'event-type', 'イベント表示切り替え' ],
  [ c_site,   'Cms::Free', 'back-btn', '戻るボタン' ],
  [ c_site,   'Cms::Free', 'mobile-global-navi', '【携帯】グローバルナビ' ],
  [ c_site,   'Cms::Free', 'sns', 'SNSボタン' ],
  [ c_mayor,  'Cms::Free', 'side-navi', '市長の部屋メニュー' ],
  [ c_site,   'Cms::Free', 'mobile-common-header', '【携帯】共通ヘッダー' ],
  [ c_top,    'Cms::Free', 'about', 'ぞめき市の紹介' ],
  [ c_top,    'Cms::Free', 'population', 'ぞめき市の人口' ],
  [ c_site,   'Cms::Free', 'mobile-back-navi', '【携帯】バックナビ' ],
  [ c_site,   'Cms::Free', 'mobile-common-footer', '【携帯】共通フッター' ],
  [ c_site,   'Cms::Free', 'mobile-copyright', '【携帯】コピーライト' ],
  [ c_site,   'Cms::Free', 'mobile-footer-navi', '【携帯】フッタナビ' ],
  [ c_top,    'Cms::Free', 'mobile-guide', '【携帯】暮らしのガイド' ],
  [ c_top,    'Cms::Free', 'mobile-lifeevent', '【携帯】ライフイベント' ],
  [ c_top,    'Cms::Free', 'mobile-navi', '【携帯】ぞめき市の紹介' ],
  [ c_top,    'Cms::Free', 'mobile-recent-docs-more', '【携帯】新着記事一覧へのリンク' ],
  [ c_site,   'Cms::Free', 'smart-global-navi', '【スマートフォン】グローバルナビ' ],
  [ c_top,    'Cms::Free', 'bn-faq', 'よくある質問FAQバナー' ],
  [ c_gnavi1, 'Cms::Free', 'global-navi1', 'グローバルナビ' ],
  [ c_gnavi2, 'Cms::Free', 'global-navi2', 'グローバルナビ' ],
  [ c_gnavi3, 'Cms::Free', 'global-navi3', 'グローバルナビ' ],
  [ c_gnavi4, 'Cms::Free', 'global-navi4', 'グローバルナビ' ],
  [ c_gnavi5, 'Cms::Free', 'global-navi5', 'グローバルナビ' ],
  [ c_site,   'Cms::Free', 'search-navi', '検索ナビ' ],
  [ c_gikai,  'Cms::Free', 'side-navi', '議会サイドメニュー' ],
  [ c_top,    'Cms::Free', 'emergency-mode', '大規模災害時モード表示' ],
  [ c_top,    'Cms::Free', 'emergency-info', '大規模災害時メニュー' ],
  [ c_top,    'Cms::Free', 'mobile-emergency-header', '【携帯】災害ヘッダー' ],
  [ c_top,    'Cms::Free', 'mobile-emergency-information', '【携帯】緊急情報' ]
].each do |c|
  create_cms_piece c[0], c[1], c[2], c[3]
end

## ---------------------------------------------------------
## cms/nodes

puts "import cms_nodes..."


def create_cms_node(parent, layout, model, name, title)
  Cms::Node.create   site_id: 1,
   concept_id:   c_site.id,
   parent_id:    parent.id ,
   state:        'public',
   route_id:     parent.id,
   directory:    (params[:name] =~ /\./ ? 0 : 1),
   published_at: Time.now,
   layout_id:    layout.id,
   model:        model,
   name:         name,
   title:        title
end

n_top   = Cms::Node.find_by(:id => 1, :parent_id => 0)
p_index = Cms::Node.find_by(:id => 2, :name => "index.html")
         create_cms_node n_top, l_top, 'Cms::Page', 'privacy.html', '個人情報の取り扱い'
         create_cms_node n_top, l_top, 'Cms::Page', '404.html', 'ページが見つかりませんでした'
         create_cms_node n_top, l_top, 'Cms::Page', 'search.html', '検索結果'
         create_cms_node n_top, l_top, 'Cms::Page', 'riyo.html', 'ホームページ利用について'
         create_cms_node n_top, l_top, 'Cms::Page', 'web_accessibility.html', 'ウェブアクセシビリティについて'
         create_cms_node n_top, l_top, 'Cms::Page', 'link.html', 'リンク集'
         create_cms_node n_top, l_top, 'Cms::Page', 'copyright.html', 'リンク・著作権・免責事項'
         create_cms_node n_top, l_top, 'Cms::Page', 'banner.html', 'バナー広告について'
         create_cms_node n_top, l_top, 'Cms::Sitemap', 'sitemap.html', 'サイトマップ'

n_mayor  = create_cms_node n_top, l_mayor, 'Cms::Directory', 'mayor', 'ぞめき市長の部屋'
         create_cms_node n_mayor, l_mayor, 'Cms::Page', 'profile.html', 'プロフィール'
         create_cms_node n_mayor, l_mayor, 'Cms::Page', 'gallery.html', '市長フォトギャラリー'
         create_cms_node n_mayor, l_mayor, 'Cms::Page', 'kosaihi.html', '市長交際費執行状況'
         create_cms_node n_mayor, l_mayor, 'Cms::Page', 'hyomei.html', '所信表明'
         create_cms_node n_mayor, l_mayor, 'Cms::Page', 'shuninaisatsu.html', '就任のごあいさつ'
         create_cms_node n_mayor, l_mayor, 'Cms::Page', 'index.html', '市長の部屋'



n_gikai  = create_cms_node n_top, l_gikai, 'Cms::Directory', 'gikai', 'ぞめき市議会'
         create_cms_node n_gikai, l_gikai, 'Cms::Page', 'kekka.html', '定例会・臨時会の結果'
         create_cms_node n_gikai, l_gikai, 'Cms::Page', 'seigan.html', '請願・陳情のご案内'
         create_cms_node n_gikai, l_gikai, 'Cms::Page', 'kensaku.html', '会議録検索'
         create_cms_node n_gikai, l_gikai, 'Cms::Page', 'dayori.html', 'ぞめき市議会だより'
         create_cms_node n_gikai, l_gikai, 'Cms::Page', 'index.html', 'ぞめき市議会'
         create_cms_node n_gikai, l_gikai, 'Cms::Page', 'meibo.html', '議員名簿'
         create_cms_node n_gikai, l_gikai, 'Cms::Page', 'kosei.html', '市議会の構成'
         create_cms_node n_gikai, l_gikai, 'Cms::Page', 'botyo.html', '傍聴のご案内'



## ---------------------------------------------------------
## each modules

load_demo "navi"
load_demo "flow"
load_demo "gp_category"
load_demo "gp_template"
load_demo "tag"
load_demo "sns"
load_demo "map"
load_demo "gp_article"
load_demo "ad_banner"
load_demo "survey"
load_demo "rank"
load_demo "feed"
load_demo "biz_calendar"

