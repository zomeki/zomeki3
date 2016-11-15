## ---------------------------------------------------------
## cms/concepts
c_site  = @site.concepts.where(parent_id: 0).first
c_top   = @site.concepts.where(name: 'トップページ').first
c_content = @site.concepts.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/layouts

l_gnavi     = create_cms_layout c_content, 'global-navi',    'グローバルナビ'

## ---------------------------------------------------------
## cms/contents
gnavi = create_cms_content c_content, 'Gnav::MenuItem', 'グローバルナビ', 'navi'
create_cms_node c_content, gnavi, 10, nil, l_gnavi, 'Gnav::MenuItem', 'navi', 'ナビ', nil

category   = GpCategory::Content::CategoryType.where(concept_id: c_content.id).first
cate_types = GpCategory::CategoryType.where(content_id: category.id).pluck(:id)
settings = Gnav::Content::Setting.config(gnavi, 'gp_category_content_category_type_id')
settings.value = category.id
settings.save

## ---------------------------------------------------------
## gnavi/menu_items

def create_menu(concept, content, layout, name, title, sort_no)
  Gnav::MenuItem.create concept_id: concept.id,
    content_id: content.id,
    state: 'public',
    name: name,
    title: title,
    sort_no: sort_no,
    layout_id: layout.id
end

kurashi  = create_menu c_content, gnavi, l_gnavi, 'kurashi',  '暮らしのガイド', 10
kosodate = create_menu c_content, gnavi, l_gnavi, 'kosodate', '子育て・教育', 20
kanko    = create_menu c_content, gnavi, l_gnavi, 'kanko',    '観光・文化',   30
jigyosha = create_menu c_content, gnavi, l_gnavi, 'jigyosha', '事業者の方へ', 40
shisei   = create_menu c_content, gnavi, l_gnavi, 'shisei',   '市政情報',    50

def create_category_sets(menu_item, category)
  Gnav::CategorySet.create menu_item_id: menu_item.id,
    category_id: category.id,
    layer: 'descendants'
end

['kankyo', 'seikatsu', 'zei', 'kenko', 'hukushi', 'hoken', 'todokede',].each do |c|
  if category = GpCategory::Category.where(category_type_id: cate_types, name: c).first
    create_category_sets kurashi, category
  end
end
['fuyo', 'ikuji'].each do |c|
  if category = GpCategory::Category.where(category_type_id: cate_types, name: c).first
    create_category_sets kosodate, category
  end
end

['access', 'bunka_sports', 'rekishi'].each do |c|
  if category = GpCategory::Category.where(category_type_id: cate_types, name: c).first
    create_category_sets kanko, category
  end
end

['suido', 'doro', 'toshiseibi', 'nyusatsu'].each do |c|
  if category = GpCategory::Category.where(category_type_id: cate_types, name: c).first
    create_category_sets jigyosha, category
  end
end

['johokokai', 'kohokocho', 'gikai_senkyo', 'shisei'].each do |c|
  if category = GpCategory::Category.where(category_type_id: cate_types, name: c).first
    create_category_sets shisei, category
  end
end
