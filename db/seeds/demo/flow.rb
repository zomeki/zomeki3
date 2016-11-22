puts 'import approval flow...'

## ---------------------------------------------------------
## cms/concepts
c_site  = @site.concepts.where(parent_id: 0).first
c_top   = @site.concepts.where(name: 'トップページ').first
c_content = @site.concepts.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
approval_flow = create_cms_content c_content, 'Approval::ApprovalFlow', '承認フロー', 'approval_flow'

somu = Sys::User.find_by(account: "#{@code_prefix}somu3")

somu_flow = Approval::ApprovalFlow.create content_id: approval_flow.id,
  title: Core.user_group.name,
  group_id: Core.user_group.id,
  sort_no: 10

approval = somu_flow.approvals.create(index: 0, approval_type: 'fix')
approval.assignments.create(user_id: somu.id, or_group_id: 0)

bosaika = @site.groups.where(code: "#{@code_prefix}1003").first
bosai   = Sys::User.find_by(account: "#{@code_prefix}bosai3")

bosai_flow = Approval::ApprovalFlow.create content_id: approval_flow.id,
  title: bosaika.name,
  group_id: bosaika.id,
  sort_no: 10

approval = bosai_flow.approvals.create(index: 0, approval_type: 'fix')
approval.assignments.create(user_id: bosai.id, or_group_id: 0)
