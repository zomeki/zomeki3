## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
l_grouop    = create_cms_layout c_site, 'soshiki',      '組織'
l_top_grp   = create_cms_layout c_site, 'soshiki-top',  '組織TOP'

organization  = create_cms_content c_content, 'Organization::Group', '組織', 'soshiki'
create_cms_content_node organization, l_top_grp, 'Organization::Group', 'soshiki', '組織'

Sys::Group.all.each do |g|
  Organization::Group.create content_id: organization.id,
    state: 'public', name: g.name_en, sys_group_code: g.code,
    sitemap_state: 'visible', docs_order: 'display_published_at DESC, published_at DESC'
end
