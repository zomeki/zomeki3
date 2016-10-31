## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
l_tag       = create_cms_layout c_site, 'tag', '関連ワード'
tag  = create_cms_content c_content, 'Tag::Tag', '関連タグ', 'tag'
create_cms_content_node tag, l_tag, 'Tag::Tag', 'tag', '関連タグ'

Tag::Tag.create content_id: tag.id,
  word: '入札'
