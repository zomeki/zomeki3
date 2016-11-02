## ---------------------------------------------------------
## cms/concepts

c_site    = Cms::Concept.find(1)
c_top     = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

c_category = create_cms_concept c_content, 40, 'カテゴリ'

c_kubun    = create_cms_concept c_category, 10, '区分'

c_bunya    = create_cms_concept c_category, 20, '分野'
c_bunya1   = create_cms_concept c_bunya,    10,'届出・登録・証明'
c_bunya2   = create_cms_concept c_bunya,    20,'保険・年金・介護'
c_bunya3   = create_cms_concept c_bunya,    30,'福祉'
c_bunya4   = create_cms_concept c_bunya,    40,'健康・予防'
c_bunya5   = create_cms_concept c_bunya,    50,'税金'
c_bunya6   = create_cms_concept c_bunya,    60,'育児・教育'
c_bunya7   = create_cms_concept c_bunya,    70,'生活・インフラ'
c_bunya8   = create_cms_concept c_bunya,    80,'安心・安全'
c_bunya9   = create_cms_concept c_bunya,    90,'環境・ごみ'
c_bunya10  = create_cms_concept c_bunya,    100,'入札・契約'
c_bunya11  = create_cms_concept c_bunya,    110,'都市整備'
c_bunya12  = create_cms_concept c_bunya,    120,'地域産業'
c_bunya13  = create_cms_concept c_bunya,    130,'市政情報'
c_bunya14  = create_cms_concept c_bunya,    140,'歴史・文化財'
c_bunya15  = create_cms_concept c_bunya,    150,'施設案内'
c_bunya16  = create_cms_concept c_bunya,    160,'市紹介'
c_bunya17  = create_cms_concept c_bunya,    170,'議会・選挙'
c_bunya18  = create_cms_concept c_bunya,    180,'広報・広聴'
c_bunya19  = create_cms_concept c_bunya,    190,'情報公開'
c_bunya20  = create_cms_concept c_bunya,    200,'交流事業'

c_lifeevent = create_cms_concept c_category, 30, 'ライフイベント'
c_event     = create_cms_concept c_category, 40, 'イベント情報'

             create_cms_concept c_category, 50, '組織'

## ---------------------------------------------------------
## cms/layouts

l_category  = create_cms_layout c_site, 'category','カテゴリ'
l_bunya     = create_cms_layout c_site, 'category-bunya', 'カテゴリ（分野）'

## ---------------------------------------------------------
## cms/contents
category = create_cms_content c_content, 'GpCategory::CategoryType', 'カテゴリ', 'category'
create_cms_node c_content, category, 20, nil, l_category, 'GpCategory::CategoryType', 'categories', 'カテゴリ', nil


[
  {id: "date_style", value: '%Y年%m月%d日'},
  {id: "category_type_style", value: 'all_categories',
    extra_values: {category_type_doc_style: '@title_link@@publish_date@@group@', doc_number: 10}},
  {id: "category_style", value: 'categories_with_docs',
    extra_values: {category_doc_style: '@title_link@@publish_date@@group@', category_docs_number: 10}},
  {id: "doc_style", value: 'all_docs',
    extra_values: {doc_doc_style: '@title_link@@publish_date@@group@', doc_docs_number: 10}}
].each do |conf|
  item = GpCategory::Content::Setting.config(category, conf[:id])
  item.value = conf[:value]
  item.extra_values = conf[:extra_values] if conf[:extra_values]
  item.save
end


## ---------------------------------------------------------
## gp_category/category_type

def create_type(concept, content, layout, name, title, sort_no)
  GpCategory::CategoryType.create concept_id: concept.id,
    content_id: content.id,
    layout_id: layout.id,
    name: name,
    title: title,
    sort_no: sort_no,
    state: 'public',
    docs_order: 'display_published_at DESC, published_at DESC'

end

kubun     = create_type c_category, category, l_category, 'kubun',      '区分', 10
bunya     = create_type c_category, category, l_bunya,    'bunya',      '分野', 20
lifeevent = create_type c_category, category, l_category, 'lifeevent',  'ライフイベント', 30
event     = create_type c_category, category, l_category, 'event',      'イベント情報', 40

def create(concept, category_type, parent, layout, name, title, sort_no)
  GpCategory::Category.create concept_id: concept.id,
    category_type_id: category_type.id,
    parent_id: parent.blank? ? nil : parent.id,
    layout_id: layout.id,
    name: name,
    title: title,
    sort_no: sort_no,
    state: 'public',
    docs_order: 'display_published_at DESC, published_at DESC'
end


todokede      = create c_bunya , bunya, nil, l_category, 'todokede', '届出・登録・証明', 10
hoken         = create c_bunya , bunya, nil, l_category, 'hoken', '保険・年金・介護', 20
hukushi       = create c_bunya , bunya, nil, l_category, 'hukushi', '福祉', 30
kenko         = create c_bunya , bunya, nil, l_category, 'kenko', '健康・予防', 40
zei           = create c_bunya , bunya, nil, l_category, 'zei', '税金', 50
ikuji         = create c_bunya , bunya, nil, l_category, 'ikuji', '育児・教育', 60
seikatsu      = create c_bunya , bunya, nil, l_category, 'seikatsu', '生活・インフラ', 70
anshin        = create c_bunya , bunya, nil, l_category, 'anshin', '安心・安全', 80
kankyo        = create c_bunya , bunya, nil, l_category, 'kankyo', '環境・ごみ', 90
nyusatsu      = create c_bunya , bunya, nil, l_category, 'nyusatsu', '入札・契約', 100
toshiseibi    = create c_bunya , bunya, nil, l_category, 'toshiseibi', '都市整備', 110
chiikisangyo  = create c_bunya , bunya, nil, l_category, 'chiikisangyo', '地域産業', 120
shisei        = create c_bunya , bunya, nil, l_category, 'shisei', '市政情報', 130
rekishi       = create c_bunya , bunya, nil, l_category, 'rekishi', '歴史・文化財', 140
shisetsu      = create c_bunya , bunya, nil, l_category, 'shisetsu', '施設案内', 150
city_shokai   = create c_bunya , bunya, nil, l_category, 'city_shokai', '市紹介', 160
gikai_senkyo  = create c_bunya , bunya, nil, l_category, 'gikai_senkyo', '議会・選挙', 170
kohokocho     = create c_bunya , bunya, nil, l_category, 'kohokocho', '広報・広聴', 180
johokokai     = create c_bunya , bunya, nil, l_category, 'johokokai', '情報公開', 190
koryu         = create c_bunya , bunya, nil, l_category, 'koryu', '交流事業', 200


chumoku = create c_kubun, kubun, nil, l_category, 'chumoku', '注目情報', 10
create c_kubun, kubun, nil, l_category, 'faq', 'FAQ', 20
create c_kubun, kubun, nil, l_category, 'tetsuzuki', '手続き', 30
create c_kubun, kubun, nil, l_category, 'boshu', '募集', 40
create c_kubun, kubun, nil, l_category, 'open_data', 'オープンデータ', 50
create c_kubun, kubun, nil, l_category, 'download', 'ダウンロード', 60
create c_lifeevent, lifeevent, nil, l_category, 'ninshin', '妊娠・出産', 10
create c_lifeevent, lifeevent, nil, l_category, 'kosodate', '子育て・教育', 20
create c_lifeevent, lifeevent, nil, l_category, 'seijin', '成人・就職', 30
create c_lifeevent, lifeevent, nil, l_category, 'kekkon', '結婚・離婚', 40
create c_lifeevent, lifeevent, nil, l_category, 'hikkoshi', '引越し・住まい', 50
create c_lifeevent, lifeevent, nil, l_category, 'byoki', '病気・けが', 60
create c_lifeevent, lifeevent, nil, l_category, 'shogaisha', '障がい者', 70
create c_lifeevent, lifeevent, nil, l_category, 'shitsugyo', '失業・退職', 80
create c_lifeevent, lifeevent, nil, l_category, 'korei', '高齢・介護', 90
create c_lifeevent, lifeevent, nil, l_category, 'shibo', '死亡・相続', 100
create c_bunya1, bunya, todokede, l_bunya, 'juminhyo', '住民票', 10
create c_bunya1, bunya, todokede, l_bunya, 'inkan', '印鑑登録', 20
create c_bunya1, bunya, todokede, l_bunya, 'koseki', '戸籍', 30
create c_bunya1, bunya, todokede, l_bunya, 'gaikokujin', '外国人登録', 40
create c_bunya1, bunya, todokede, l_bunya, 'shomei', '各種証明書', 50
create c_bunya1, bunya, todokede, l_bunya, 'jukinet', '住基ネット・公的個人認証', 60
create c_bunya1, bunya, todokede, l_bunya, 'passport', 'パスポート', 70
create c_bunya1, bunya, todokede, l_bunya, 'my-number', 'マイナンバー制度', 80
create c_bunya1, bunya, todokede, l_bunya, 'procedure', '手続き・本人確認・委任', 90
create c_bunya2, bunya, hoken, l_bunya, 'kokuho', '国民健康保険', 10
create c_bunya2, bunya, hoken, l_bunya, 'nenkin', '国民年金', 20
create c_bunya2, bunya, hoken, l_bunya, 'kaigo', '介護保険', 30
create c_bunya2, bunya, hoken, l_bunya, 'kouki', '後期高齢者医療', 40
create c_bunya3, bunya, hukushi, l_bunya, 'fuyo', '児童扶養手当', 10
create c_bunya3, bunya, hukushi, l_bunya, 'hitori', 'ひとり親家庭助成', 20
create c_bunya3, bunya, hukushi, l_bunya, 'tokubetsu', '特別児童扶養手当', 30
create c_bunya3, bunya, hukushi, l_bunya, 'shogai', '障がい者助成', 40
create c_bunya3, bunya, hukushi, l_bunya, 'korei', '高齢者福祉', 50
create c_bunya3, bunya, hukushi, l_bunya, 'seikatsuhogo', '生活保護', 60
create c_bunya4, bunya, kenko, l_bunya, 'boshihoken', '母子保健', 10
create c_bunya4, bunya, kenko, l_bunya, 'yobo', '予防接種', 20
create c_bunya4, bunya, kenko, l_bunya, 'tokuteikenshin', '総合健(検)診【特定健診等】･保健指導', 30
create c_bunya4, bunya, kenko, l_bunya, 'kenko', '健康づくり', 40
create c_bunya4, bunya, kenko, l_bunya, 'sonota', 'その他', 50
create c_bunya4, bunya, zei, l_bunya, 'kobai', '公売情報', 80
create c_bunya5, bunya, zei, l_bunya, 'shikenmin', '市県民税', 10
create c_bunya5, bunya, zei, l_bunya, 'shizei_gaiyo', '市税概要', 20
create c_bunya5, bunya, zei, l_bunya, 'koteishisan', '固定資産税', 30
create c_bunya5, bunya, zei, l_bunya, 'keijidosha', '軽自動車税', 40
create c_bunya5, bunya, zei, l_bunya, 'sonota', 'その他の税', 50
create c_bunya5, bunya, zei, l_bunya, 'nofu', '納付・収納', 60
create c_bunya5, bunya, zei, l_bunya, 'shomeisho', '税務関連証明書', 70
create c_bunya6, bunya, ikuji, l_bunya, 'hoikusho', '保育所', 10
create c_bunya6, bunya, ikuji, l_bunya, 'yochien', '幼稚園', 20
create c_bunya6, bunya, ikuji, l_bunya, 'ikujishien', '育児支援', 30
create c_bunya6, bunya, ikuji, l_bunya, 'gakudohoiku', '学童保育', 40
create c_bunya6, bunya, ikuji, l_bunya, 'shochugakko', '小学校・中学校', 50
create c_bunya6, bunya, ikuji, l_bunya, 'kyushoku', '給食', 60
create c_bunya6, bunya, ikuji, l_bunya, 'shogaigakushu', '生涯学習', 70
create c_bunya6, bunya, ikuji, l_bunya, 'shugakutaiyo', '就学資金貸与', 80
create c_bunya7, bunya, seikatsu, l_bunya, 'koeijutaku', '公営住宅', 10
create c_bunya7, bunya, seikatsu, l_bunya, 'suido', '上水道', 20
create c_bunya7, bunya, seikatsu, l_bunya, 'gesuido', '下水道', 30
create c_bunya7, bunya, seikatsu, l_bunya, 'doro', '道路', 40
create c_bunya7, bunya, seikatsu, l_bunya, 'kokyo', '公共共通（電車・バスなど）', 50
create c_bunya8, bunya, anshin, l_bunya, 'kyukyu', '救急・消防', 10
create c_bunya8, bunya, anshin, l_bunya, 'kyujitsushinryo', '休日診療案内', 20
create c_bunya8, bunya, anshin, l_bunya, 'bosaigai', '防災・災害', 30
create c_bunya8, bunya, anshin, l_bunya, 'bohan', '防犯・交通安全', 40
create c_bunya8, bunya, anshin, l_bunya, 'jiko', '事故・被災支援', 50
create c_bunya9, bunya, kankyo, l_bunya, 'gomi', 'ごみ・リサイクル', 10
create c_bunya9, bunya, kankyo, l_bunya, 'pet', 'ペット・動物愛護', 20
create c_bunya9, bunya, kankyo, l_bunya, 'kogai_bochi', '公害・墓地', 30
create c_bunya9, bunya, kankyo, l_bunya, 'eco', 'エコ・環境', 40
create c_bunya10, bunya, nyusatsu, l_bunya, 'joho', '入札情報', 10
create c_bunya10, bunya, nyusatsu, l_bunya, 'kobo', '公募', 20
create c_bunya10, bunya, nyusatsu, l_bunya, 'shikakushinsei', '入札参加資格申請', 30
create c_bunya10, bunya, nyusatsu, l_bunya, 'shokibokoji', '小規模工事等業者登録', 40
create c_bunya10, bunya, nyusatsu, l_bunya, 'henko', '入札参加資格申請変更届け', 50
create c_bunya11, bunya, toshiseibi, l_bunya, 'keikaku', '都市計画・まちづくり', 10
create c_bunya11, bunya, toshiseibi, l_bunya, 'doro', '道路整備', 20
create c_bunya12, bunya, chiikisangyo, l_bunya, 'kigyoyushi', '企業融資・支援', 10
create c_bunya12, bunya, chiikisangyo, l_bunya, 'noringyo', '農業・林業', 20
create c_bunya12, bunya, chiikisangyo, l_bunya, 'shokogyo', '商業・工業', 30
create c_bunya12, bunya, chiikisangyo, l_bunya, 'koyo', '雇用', 40
create c_bunya13, bunya, shisei, l_bunya, 'aramashi', '市のあらまし', 10
create c_bunya13, bunya, shisei, l_bunya, 'kyodosankaku', '男女共同参画', 20
create c_bunya14, bunya, rekishi, l_bunya, 'bunkazai_shiseki', '歴史と文化財', 10
create c_bunya14, bunya, rekishi, l_bunya, 'bunkazaimap', '文化財マップ・リーフレット等のダウンロード', 20
create c_bunya14, bunya, rekishi, l_bunya, 'eventnews', 'イベント・ニュース', 30
create c_bunya15, bunya, shisetsu, l_bunya, 'shiyakusho', '市役所', 10
create c_bunya15, bunya, shisetsu, l_bunya, 'hukushi', '福祉・保健施設', 20
create c_bunya15, bunya, shisetsu, l_bunya, 'bunka_sports', '文化・スポーツ施設', 30
create c_bunya15, bunya, shisetsu, l_bunya, 'hoikusho', '保育所', 40
create c_bunya15, bunya, shisetsu, l_bunya, 'yochien', '幼稚園', 50
create c_bunya15, bunya, shisetsu, l_bunya, 'shochugakko', '小中学校・高校', 60
create c_bunya15, bunya, shisetsu, l_bunya, 'kominkan', '公民館', 70
create c_bunya15, bunya, shisetsu, l_bunya, 'center', '男女共同参画推進ハーモニーセンター', 80
create c_bunya15, bunya, shisetsu, l_bunya, 'chuokominkan', '中央公民館', 90
create c_bunya15, bunya, shisetsu, l_bunya, 'koen', '公園', 100
create c_bunya15, bunya, shisetsu, l_bunya, 'shieijyutaku', '市営住宅', 110
create c_bunya15, bunya, shisetsu, l_bunya, 'shisetsu_guide', '施設ガイド', 120
create c_bunya16, bunya, city_shokai, l_bunya, 'chosha', '庁舎案内', 10
create c_bunya16, bunya, city_shokai, l_bunya, 'access', '市へのアクセス', 20
create c_bunya16, bunya, city_shokai, l_bunya, 'madoguchi', '窓口対応時間', 30
create c_bunya16, bunya, city_shokai, l_bunya, 'floor_guide', '庁舎フロアガイド', 40
create c_bunya16, bunya, city_shokai, l_bunya, 'soshiki', '組織', 50
create c_bunya16, bunya, city_shokai, l_bunya, 'saiyo', '職員採用', 60
create c_bunya17, bunya, gikai_senkyo, l_bunya, 'gikai', '議会', 10
create c_bunya17, bunya, gikai_senkyo, l_bunya, 'senkyo', '選挙', 20
create c_bunya18, bunya, kohokocho, l_bunya, 'koho', '広報', 10
create c_bunya18, bunya, kohokocho, l_bunya, 'kocho', '広聴', 20
create c_bunya18, bunya, kohokocho, l_bunya, 'shiminnokoe', '市民の声', 30
create c_bunya18, bunya, kohokocho, l_bunya, 'questionnaire', '住民アンケート', 40
create c_bunya18, bunya, kohokocho, l_bunya, 'gyoseisodan', '行政相談窓口', 50
create c_bunya18, bunya, kohokocho, l_bunya, 'kokoku', '広告掲載案内', 60
create c_bunya19, bunya, johokokai, l_bunya, 'johokokai_kojinjoho', '情報公開・個人情報制度', 10
create c_bunya19, bunya, johokokai, l_bunya, 'keikaku', '計画・取り組み', 20
create c_bunya19, bunya, johokokai, l_bunya, 'zaisei', '財政状況', 30
create c_bunya19, bunya, johokokai, l_bunya, 'tokei', '統計', 40
create c_bunya19, bunya, johokokai, l_bunya, 'jorei_reiki', '条例・例規集', 50
create c_bunya19, bunya, johokokai, l_bunya, 'kyuyoteisu', '職員給与・定員管理', 60
create c_bunya20, bunya, koryu, l_bunya, 'kokusai', '国際交流', 10
create c_bunya19, bunya, koryu, l_bunya, 'heiwakoryu', '平和交流', 20
create c_bunya20, bunya, koryu, l_bunya, 'yukotoshikoryu', '友好都市交流', 30
create c_event, event, nil, l_category, 'event', 'イベント', 10
create c_event, event, nil, l_category, 'sports', 'スポーツ', 20
create c_event, event, nil, l_category, 'koza', '講座', 30
create c_event, event, nil, l_category, 'matsuri', 'お祭り', 40

## ---------------------------------------------------------
## cms/pieces
p_lifeevent = create_cms_piece c_site, category, 'GpCategory::CategoryList', 'lifeevent-list', 'ライフイベント一覧', '人生のできごとから探す'
p_lifeevent.in_settings = {setting_state: 'enabled', category_type_id: lifeevent.id, layer: 'descendants'}
p_lifeevent.save

p_category = create_cms_piece c_category, category, 'GpCategory::CategoryList', 'category-list', 'カテゴリから探す', 'カテゴリから探す'
p_category.in_settings = {setting_state: 'enabled', layer: 'self'}
p_category.save

