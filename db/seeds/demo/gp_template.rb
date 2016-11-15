## ---------------------------------------------------------
## cms/concepts

c_site  = @site.concepts.where(parent_id: 0).first
c_top   = @site.concepts.where(name: 'トップページ').first
c_content = @site.concepts.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
template = create_cms_content c_content, 'GpTemplate::Template', 'テンプレート', 'template'

copyright = GpTemplate::Template.create content_id: template.id,
  state: 'public',
  title: '著作権標記有り',
  body: read_data("templates/template/body.txt"),
  sort_no: 10
