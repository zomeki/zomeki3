puts 'import approval flow...'

## ---------------------------------------------------------
## cms/concepts
c_site  = @site.concepts.where(parent_id: 0).first
c_top   = @site.concepts.where(name: 'トップページ').first
c_content = @site.concepts.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
approval_flow = create_cms_content c_content, 'Approval::ApprovalFlow', '承認フロー', 'approval_flow'

flow = Approval::ApprovalFlow.create content_id: approval_flow.id,
  title: 'ぞめき',
  group_id: Core.user_group.id,
  sort_no: 10

approval = flow.approvals.create(index: 0, approval_type: 'fix')
approval.assignments.create(user_id: Core.user.id, or_group_id: 0)

