## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
feed = create_cms_content c_content, 'Feed::Feed', 'フィード', 'feed'

l_col1 = Cms::Layout.where(name: 'col-1').first
create_cms_node c_content, feed, 100, nil, l_col1, 'Feed::FeedEntry', 'feed', '新着記事一覧', nil
