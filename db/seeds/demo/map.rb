## ---------------------------------------------------------
## cms/concepts
c_site  = @site.concepts.where(parent_id: 0).first
c_top   = @site.concepts.where(name: 'トップページ').first
c_content = @site.concepts.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents

l_map     = create_cms_layout c_content, 'map', '施設案内'

map  = create_cms_content c_content, 'Map::Marker', '施設案内', 'map'
create_cms_node c_content, map, 160, nil, l_map, 'Map::Marker', 'map', '施設案内', nil
category = GpCategory::Content::CategoryType.where(concept_id: c_content.id).first
cate_types = GpCategory::CategoryType.where(content_id: category.id).pluck(:id)
shisetsu = GpCategory::Category.where(category_type_id: cate_types, name: 'shisetsu').first
map_category = {'0' => shisetsu.id}

[
  {id: 'gp_category_content_category_type_id', value: category.id,
      extra_values: {categories: map_category}},
  {id: 'lat_lng', value: '35.402967,139.314963'},
  {id: 'show_images', value: 'visible'},
  {id: 'default_image', value: '/_themes/base/images/sample.gif'},
  {id: 'marker_order', value: 'category'},
  {id: 'title_style', value: '@title_link@'},
].each do |conf|
  item = Map::Content::Setting.config(map, conf[:id])
  item.value = conf[:value]
  item.extra_values = conf[:extra_values] if conf[:extra_values]
  item.save
end

def create(content, title, lat, lng, window_text, parent_category, category_item)
  category_ids = GpCategory::Category.where(parent_id: parent_category.id, name: category_item).pluck(:id)
  Map::Marker.create content_id: content.id,
    state: 'public',
    title: title,
    latitude: lat,
    longitude: lng,
    window_text: window_text,
    category_ids: category_ids
end


create map, 'ぞめき市役所',  35.69917115852184, 139.55803585056856, 'ぞめき市役所<br />〒164-0002 三鷹市上連雀2-6-7<br />0422-26-9151', shisetsu, 'shiyakusho'
create map, 'ぞめき市図書館', 35.68516845714433, 139.55816459651942, 'ぞめき市図書館', shisetsu, 'bunka_sports'
create map, 'ぞめき市美術館', 35.70155611615214, 139.56072995066165, 'ぞめき市美術館', shisetsu, 'bunka_sports'
create map, 'ぞめき市総合保健センター', 35.68234918496953, 139.56397676467418, 'ぞめき市総合保健センター', shisetsu, 'hukushi'
create map, 'ぞめき市民体育館', 35.68256730482748, 139.55904217063903, 'ぞめき市民体育館', shisetsu, 'bunka_sports'
create map, '地域包括支援センター', 35.68599970017181, 139.5713474750471 , '地域包括支援センター', shisetsu, 'hukushi'
create map, 'ファミリーサポートセンター', 35.69595836619496, 139.56037522851943, 'ファミリーサポートセンター', shisetsu, 'hukushi'
create map, 'ぞめき消防署', 35.68289028961057, 139.56602463125705, 'ぞめき消防署', shisetsu, 'shiyakusho'

