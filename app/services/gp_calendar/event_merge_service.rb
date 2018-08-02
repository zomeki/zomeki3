class GpCalendar::EventMergeService < ApplicationService
  def initialize(content)
    @content = content
  end

  def merge(events, docs, range = nil)
    events = events + docs_to_events(docs)
    drop_out_of_range_periods(events, range) if range
    sort_events(events)
  end

  private

  def docs_to_events(docs)
    docs = GpArticle::DocsPreloader.new(docs).preload(:public_node_ancestors, :event_categories, :files)
    docs.map { |doc| GpCalendar::Event.from_doc(doc, @content) }
  end

  def drop_out_of_range_periods(events, range)
    events.each do |event|
      event.periods.to_a.delete_if { |period| period.intersect?(range[0], range[1]) }
    end
  end

  def sort_events(events)
    events.sort_by do |event|
      [event.periods.map(&:started_on).min || Time.now(0), event.periods.map(&:ended_on).min || Time.now(0)]
    end
  end
end
