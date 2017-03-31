class GpCalendar::Public::Piece::BaseController < Sys::Controller::Public::Base
  private

  def merge_docs_into_events(docs, events)
    merged = events + docs.map { |doc| GpCalendar::Event.from_doc(doc, @piece.content) }
    merged.sort { |a, b| a.started_on <=> b.started_on }
  end
end
