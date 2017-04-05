module GpCalendar::SyncEvent
  extend ActiveSupport::Concern

  def gp_calendar_sync_events_export(doc_or_event:, event_content: nil)
    return unless doc_or_event.kind_of?(GpArticle::Doc) || doc_or_event.kind_of?(GpCalendar::Event)
    return if doc_or_event.kind_of?(GpArticle::Doc) && event_content.nil?
    return if doc_or_event.new_record?

    event = if doc_or_event.kind_of?(GpCalendar::Event)
              doc_or_event
            else
              gp_calendar_doc_to_event(doc: doc_or_event, event_content: event_content)
            end

    return unless event.kind_of?(GpCalendar::Event)

    version = '20150201'
    source_host = URI.parse(event.content.site.full_uri).host
    destination_hosts = event.content.event_sync_destination_hosts.split(',').each(&:strip!)

    destination_hosts.each do |host|
      begin
        conn = Faraday.new(url: "http://#{host}") do |builder|
            builder.use :cookie_jar
            builder.request :url_encoded
            builder.adapter Faraday.default_adapter
          end
        token = JSON.parse(conn.get('/_api/authenticity_token', version: version).body)['authenticity_token']
        source_class = event.doc.class.name if event.doc
        source_class ||= event.class.name

        query = {version: version, authenticity_token: token,
                 source_host: source_host, content_id: event.content_id, event_id: event.id, event_source_class: source_class}
        res = conn.post '/_api/gp_calendar/sync_events/invoke', query
        warn_log "#{__FILE__}:#{__LINE__} #{res.headers['status']}" unless res.success?
      rescue => e
        warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
      end
    end
  end

  def gp_calendar_doc_to_event(doc:, event_content:)
    return if (doc_id = doc.name.to_i).zero?
    return if doc.event_started_on.blank?

    event = GpCalendar::Event.from_doc(doc, event_content)
    event.id = doc_id
    event.started_on = doc.event_started_on
    event.ended_on = doc.event_ended_on || doc.event_started_on
    event.updated_at = doc.updated_at
    event.doc = doc
    event
  end
end
