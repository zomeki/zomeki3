class UpdateSerialNoOnGpArticleDocs < ActiveRecord::Migration
  def up
    GpArticle::Doc.unscoped.order(:id).each do |doc|
      if doc.prev_edition.present? && doc.prev_edition.serial_no.present?
        seq = doc.prev_edition.serial_no
      else
        seq = Util::Sequencer.next_id('gp_article_doc_serial_no', :version => doc.content_id)
      end
      doc.update_columns(serial_no: seq)
    end
  end

  def down
    GpArticle::Doc.unscoped.update_all(serial_no: nil)
  end
end
