class GpCalendar::Public::Piece::BaseController < Sys::Controller::Public::Base
  private

  def event_docs(start_date, end_date)
    doc_contents = Cms::ContentSetting.where(name: 'calendar_relation', value: 'enabled')
                                      .map{|cs| cs.content if cs.extra_values[:calendar_content_id] == @piece.content.id }.compact
    doc_contents.select! {|dc| dc.site == Page.site }
    return [] if doc_contents.empty?

    doc_contents.map {|dc|
      case dc.model
      when 'GpArticle::Doc'
        dc = GpArticle::Content::Doc.find(dc.id)
        dc.public_docs.where(event_state: 'visible').event_scheduled_between(start_date, end_date)
          .preload_assocs(:public_node_ancestors_assocs, :event_categories)
      else
        []
      end
    }.flatten
  end

  def merge_docs_into_events(docs, events)
    docs.each do |doc|
      event = GpCalendar::Event.new(
        title: doc.title, href: doc.public_uri, target: '_self',
        started_on: doc.event_started_on, ended_on: doc.event_ended_on, 
        description: doc.summary, content: @piece.content, will_sync: 'disabled'
      )
      event.categories = doc.event_categories
      event.files = doc.files
      event.doc = doc

      events << event
    end
    events.sort! {|a, b| a.started_on <=> b.started_on }
  end
end
