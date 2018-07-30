class GpCalendar::Public::PieceController < Cms::Controller::Public::Piece
  include GpArticle::Controller::Public::Scoping

  private

  def merge_events_and_docs(content, events, docs)
    sort_events(events + docs_to_events(content, docs))
  end

  def docs_to_events(content, docs)
    docs = GpArticle::DocsPreloader.new(docs).preload(:public_node_ancestors, :event_categories, :files)
    docs.map { |doc| GpCalendar::Event.from_doc(doc, content) }
  end

  def sort_events(events)
    events.sort_by { |e| e.started_on || Time.new(0) }
  end
end
