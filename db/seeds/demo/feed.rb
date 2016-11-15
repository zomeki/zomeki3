## ---------------------------------------------------------
## cms/concepts

c_site  = @site.concepts.where(parent_id: 0).first
c_top   = @site.concepts.where(name: 'トップページ').first
c_content = @site.concepts.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
feed = create_cms_content c_content, 'Feed::Feed', 'フィード', 'feed'

l_col1 = Cms::Layout.where(site_id: @site.id, name: 'col-1').first
create_cms_node c_content, feed, 100, nil, l_col1, 'Feed::FeedEntry', 'feed', '新着記事一覧', nil
