class MigrateSiteIdOnSysSequences < ActiveRecord::Migration[5.0]
  def up
    date_seqs = Sys::Sequence.where(name: %w(gp_article_docs gp_calendar_events map_markers)).all
    date_seqs.update_all(site_id: 1)
    Cms::Site.where.not(id: 1).each do |site|
      date_seqs.each do |seq|
        Sys::Sequence.create(seq.attributes.except('id').merge(site_id: site.id))
      end
    end

    content_seqs = Sys::Sequence.where(name: %w(gp_article_doc_serial_no reception_applicants)).all
    content_seqs.each do |seq|
      if (content = Cms::Content.find_by(id: seq.version))
        seq.update_column(:site_id, content.site_id)
      end
    end
  end
end
