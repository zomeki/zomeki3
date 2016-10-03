class SetRecognizedAtOnGpArticleDocs < ActiveRecord::Migration
  def up
    execute <<-SQL
      update gp_article_docs set recognized_at = (
        select max(a.approved_at) from approval_approval_requests as r, approval_assignments as a
          where r.approvable_id = gp_article_docs.id and
                r.approvable_type = 'GpArticle::Doc' and
                a.assignable_id = r.id and
                a.assignable_type = 'Approval::ApprovalRequest'
      );
    SQL
  end
end
