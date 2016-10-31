## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
l_doc = Cms::Layout.where(name: 'doc').first
rank  = create_cms_content c_content, 'Rank::Rank', 'アクセスランキング', 'ranking'
create_cms_content_node rank, l_doc, 'Rank::LastMonth', 'ranking', 'アクセスランキング'

