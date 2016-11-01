## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
l_tag       = create_cms_layout c_site, 'tag', '関連ワード'
tag  = create_cms_content c_content, 'Tag::Tag', '関連ワード', 'tag'
create_cms_node c_content, tag, 170, nil, l_tag, 'Tag::Tag', 'tags', '関連ワード', nil

settings = Tag::Content::Setting.config(tag, 'date_style')
settings.value = '%Y年%m月%d日 %H時%M分'
settings.save


Tag::Tag.create content_id: tag.id,
  word: '入札'




create_cms_piece c_site, tag, 'Tag::Tag', 'tag-list', '関連ワード一覧'