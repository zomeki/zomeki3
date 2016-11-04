## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first
c_group   = Cms::Concept.where(name: '組織').first

## ---------------------------------------------------------
## cms/contents
l_grouop    = create_cms_layout c_site, 'soshiki',      '組織'
l_top_grp   = create_cms_layout c_site, 'soshiki-top',  '組織TOP'

organization  = create_cms_content c_content, 'Organization::Group', '組織一覧', 'soshiki'
create_cms_node c_content, organization, 120, nil, l_top_grp, 'Organization::Group', 'soshiki', '組織', nil

category   = GpCategory::Content::CategoryType.first
settings = Organization::Content::Setting.config(organization, 'gp_category_content_category_type_id')
settings.value = category.id
settings.save


Sys::Group.where(Sys::Group.arel_table[:level_no].not_eq(1)).each do |g|
  Organization::Group.create content_id: organization.id, sort_no: g.sort_no,
    state: 'public', name: g.name_en, sys_group_code: g.code,
    sitemap_state: 'visible', docs_order: 'display_published_at DESC, published_at DESC'
end

## ---------------------------------------------------------
## cms/pieces

create_cms_piece c_group, organization, 'Organization::AllGroup', 'soshiki-list', '組織一覧'
create_cms_piece c_group, organization, 'Organization::BusinessOutline', 'business-outline', '業務内容'
create_cms_piece c_group, organization, 'Organization::Outline', 'soshiki-introduce', '組織の紹介'

address = create_cms_piece c_group, organization, 'Organization::ContactInformation', 'soshiki-address', '連絡先'
address.in_settings = {source: 'organization_group'}
address.save
