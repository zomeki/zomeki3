class GpCalendar::Public::Piece::BaseController < Sys::Controller::Public::Base
  private

  def merge_docs_into_events(docs, events)
    docs = GpArticle::DocsPreloader.new(docs).preload(:public_node_ancestors, :event_categories, :files)
    merged = events + docs.map { |doc| GpCalendar::Event.from_doc(doc, @piece.content) }
    merged.sort_by { |e| e.started_on || Time.new(0) }
  end
end
