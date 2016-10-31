
## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
key_visual = create_cms_content c_content, 'AdBanner::Banner', 'キービジュアル', 'key_visual'
ad_banner  = create_cms_content c_content, 'AdBanner::Banner', '広告バナー', 'ad_banner'

create_cms_content_node key_visual, nil, 'AdBanner::Banner', 'banner', '広告バナー'
create_cms_content_node ad_banner,  nil, 'AdBanner::Banner', 'banner', '広告バナー'

key_group = AdBanner::Group.create content_id: key_visual.id,
  title: 'トップキービジュアル',
  name: 'keyvisual',
  sort_no: 10

footer = AdBanner::Group.create content_id: ad_banner.id,
  title: 'フッタ',
  name: 'footer',
  sort_no: 10

side   = AdBanner::Group.create content_id: ad_banner.id,
  title: 'サイド',
  name: 'side',
  sort_no: 20

def create(content, file_path, mime_type, name, title, sort_no, group, advertiser_name)
  AdBanner::Banner.create content_id: content.id,
    site_id: content.site_id,
    advertiser_name: advertiser_name,
    file: Sys::Lib::File::NoUploadedFile.new("#{Rails.root}/db/seeds/demo/#{file_path}", :mime_type => mime_type),
    name: name,
    title: title,
    sort_no: sort_no,
    group_id: group.id,
    state: 'public',
    url: '#',
    target: '_blank'
end

## ---------------------------------------------------------
## cms/pieces
key = create_cms_piece c_site, 'AdBanner::Banner', 'keyvisual', 'キービジュアル', key_visual.id
key.in_settings = {group_id: key_group.id, impl: 'static', sort: 'ordered'}
key.save

footer = create_cms_piece c_top, 'AdBanner::Banner', 'bn-advertisement', ' 広告バナー（フッター）', ad_banner.id
footer.in_settings = {group_id: key_group.id, impl: 'static', sort: 'ordered'}
footer.save

side = create_cms_piece c_top, 'AdBanner::Banner', 'bn-advertisement-side', '広告バナー（サイド）', ad_banner.id
side.in_settings = {group_id: key_group.id, impl: 'static', sort: 'ordered'}
side.save


create key_visual, 'keyvisual/keyvisual1.jpg', 'image/jpeg', 'keyvisual1.jpg', '花の写真', 10, key_group, 'ぞめき市'
create key_visual, 'keyvisual/keyvisual2.jpg', 'image/jpeg', 'keyvisual2.jpg', '花の写真', 20, key_group, 'ぞめき市'
create key_visual, 'keyvisual/keyvisual3.jpg', 'image/jpeg', 'keyvisual3.jpg', '緑の写真', 30, key_group, 'ぞめき市'

create ad_banner, 'ad_banner/footer/bn-zomeki_onlin.gif', 'image/gif',
  'bn-zomeki_onlin.gif', 'ZOMEKIオンライン', 10, footer, 'サイトブリッジ株式会社'
  create ad_banner, 'ad_banner/footer/bn-Joruri_onlin.gif', 'image/gif',
  'bn-Joruri_onlin.gif', 'Joruriオンライン', 20, footer, 'サイトブリッジ株式会社'
create ad_banner, 'ad_banner/footer/bn-kokoku-footer.gif', 'image/gif',
  'bn-kokoku-footer.gif', '広告バナー', 30, footer, 'ぞめき市'

create ad_banner, 'ad_banner/side/bn-zomeki.gif', 'image/gif',
  'bn-zomeki.gif', 'ZOMEKI', 10, side, 'サイトブリッジ株式会社'
create ad_banner, 'ad_banner/side/bn-sitebridge.gif', 'image/gif',
  'bn-sitebridge.gif', 'サイトブリッジ株式会社', 10, side, 'サイトブリッジ株式会社'
create ad_banner, 'ad_banner/side/bn-kokoku.gif', 'image/gif',
  'bn-kokoku.gif', '広告バナー', 30, side, 'ぞめき市'
