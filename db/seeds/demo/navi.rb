## ---------------------------------------------------------
## cms/concepts
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/layouts

l_gnavi     = create_cms_layout c_content, 'global-navi',    'グローバルナビ'

## ---------------------------------------------------------
## cms/contents
gnavi = create_cms_content c_content, 'Gnav::MenuItem', 'グローバルナビ', 'navi'
create_cms_content_node gnavi, l_gnavi, 'Gnav::MenuItem', 'navi', 'ナビ'

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

kurashi  = create_menu c_content, gnavi, l_gnavi, 'kurashi',  '暮らしのガイド',  10
kosodate = create_menu c_content, gnavi, l_gnavi, 'kosodate', '子育て・教育',  20
kanko    = create_menu c_content, gnavi, l_gnavi, 'kanko',    '観光・文化',   30
jigyosha = create_menu c_content, gnavi, l_gnavi, 'jigyosha', '事業者の方へ',  40
shisei   = create_menu c_content, gnavi, l_gnavi, 'shisei',   '市政情報',     50

def create_category_sets(menu_item, category)
  Gnav::CategorySet.create menu_item_id: menu_item.id,
    category_id: category.id,
    layer: 'descendants'
end

['todokede', 'hoken', 'hukushi', 'kenko', 'zei', 'seikatsu', 'kankyo'].each do |c|
  if category = GpCategory::Category.where(name: c).first
    create_category_sets kurashi, category
  end
end
['ikuji' 'fuyo'].each do |c|
  if category = GpCategory::Category.where(name: c).first
    create_category_sets kosodate, category
  end
end

['rekishi', 'bunka_sports', 'access'].each do |c|
  if category = GpCategory::Category.where(name: c).first
    create_category_sets kanko, category
  end
end

['nyusatsu', 'toshiseibi', 'doro', 'suido'].each do |c|
  if category = GpCategory::Category.where(name: c).first
    create_category_sets jigyosha, category
  end
end

['shisei', 'gikai_senkyo', 'kohokocho', 'johokokai'].each do |c|
  if category = GpCategory::Category.where(name: c).first
    create_category_sets jigyosha, category
  end
end
