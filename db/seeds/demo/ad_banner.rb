
## ---------------------------------------------------------
## cms/concepts

c_site  = @site.concepts.where(parent_id: 0).first
c_top   = @site.concepts.where(name: 'トップページ').first
c_content = @site.concepts.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
ad_banner  = create_cms_content c_content, 'AdBanner::Banner', '広告バナー', 'ad_banner'
key_visual = create_cms_content c_content, 'AdBanner::Banner', 'キービジュアル', 'key_visual'

ad_setting = AdBanner::Content::Setting.config(ad_banner, 'click_count_setting')
ad_setting.value = 'enabled'
ad_setting.save

key_setting = AdBanner::Content::Setting.config(key_visual, 'click_count_setting')
key_setting.value = 'enabled'
key_setting.save

create_cms_node c_content, ad_banner,  200, nil, nil, 'AdBanner::Banner', 'banner', '広告バナー', nil
create_cms_node c_content, key_visual, 210, nil, nil, 'AdBanner::Banner', 'keyvisual', 'キービジュアル', nil

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
key_piece = create_cms_piece c_site, key_visual, 'AdBanner::Banner', 'keyvisual', 'キービジュアル'
key_piece.in_settings = {group_id: key_group.id, impl: 'static', sort: 'ordered'}
key_piece.save

footer_piece = create_cms_piece c_top, ad_banner, 'AdBanner::Banner', 'bn-advertisement', '広告バナー（フッター）', '広告バナー（フッター）'
footer_piece.in_settings = {group_id: footer.id, impl: 'static', sort: 'ordered', lower_text: '<a href="/banner.html"><span>バナー広告について</span></a>'}
footer_piece.save

side_piece = create_cms_piece c_top, ad_banner, 'AdBanner::Banner', 'bn-advertisement-side', '広告バナー（サイド）', '広告バナー（サイド）'
side_piece.in_settings = {group_id: side.id, impl: 'static', sort: 'ordered'}
side_piece.save


create key_visual, 'keyvisual/keyvisual1.jpg', 'image/jpeg', 'keyvisual1.jpg', '花の写真', 10, key_group, 'ぞめき市'
create key_visual, 'keyvisual/keyvisual2.jpg', 'image/jpeg', 'keyvisual2.jpg', '花の写真', 20, key_group, 'ぞめき市'
create key_visual, 'keyvisual/keyvisual3.jpg', 'image/jpeg', 'keyvisual3.jpg', '緑の写真', 30, key_group, 'ぞめき市'

create ad_banner, 'ad_banner/footer/bn-zomeki_Online.gif', 'image/gif', 'bn-zomeki_Online.gif', 'ZOMEKIオンライン', 10, footer, 'サイトブリッジ株式会社'
create ad_banner, 'ad_banner/footer/bn-Joruri_Online.gif', 'image/gif', 'bn-Joruri_Online.gif', 'Joruriオンライン', 20, footer, 'サイトブリッジ株式会社'
create ad_banner, 'ad_banner/footer/bn-kokoku-footer.gif', 'image/gif','bn-kokoku-footer.gif', '広告バナー', 30, footer, 'ぞめき市'

create ad_banner, 'ad_banner/side/bn-zomeki.gif', 'image/gif', 'bn-zomeki.gif', 'ZOMEKI', 10, side, 'サイトブリッジ株式会社'
create ad_banner, 'ad_banner/side/bn-sitebridge.gif', 'image/gif', 'bn-sitebridge.gif', 'サイトブリッジ株式会社', 20, side, 'サイトブリッジ株式会社'
create ad_banner, 'ad_banner/side/bn-kokoku.gif', 'image/gif', 'bn-kokoku.gif', '広告バナー', 30, side, 'ぞめき市'
