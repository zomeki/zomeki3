class GpCalendar::Public::Api::SyncEventsController < Cms::Controller::Public::Api
  include GpCalendar::SyncEvent

  def pre_dispatch
    return http_error(404) unless params[:version] == '20150201'
  end

  def invoke
    return http_error(405) unless request.post?

    event_source_class = params[:event_source_class].to_s
    event_id = params[:event_id].to_i
    content_id = params[:content_id].to_i
    source_host = params[:source_host].to_s
    return render(json: {result: 'NG'}) if content_id.zero?

    GpCalendar::Content::Event.find_each do |content|
      next unless content.event_sync_import?
      hosts = content.event_sync_source_hosts.split(',').each(&:strip!)
      next unless hosts.include?(source_host)

      begin
        conn = Faraday.new(url: "http://#{source_host}") do |builder|
            builder.adapter Faraday.default_adapter
          end
        query = {version: '20150201', content_id: content_id,
                 target_content_id: content.id, target_host: URI.parse(content.site.full_uri).host}
        res = conn.get '/_api/gp_calendar/sync_events/updated_events', query

        if res.success?
          closed_key = {sync_source_host: source_host,
                        sync_source_content_id: content_id,
                        sync_source_id: event_id,
                        sync_source_source_class: event_source_class}

          events = JSON.parse(res.body)
          events.each do |event|
            next unless event.kind_of?(Hash)
            key = {sync_source_host: source_host,
                   sync_source_content_id: content_id,
                   sync_source_id: event['id'].to_i,
                   sync_source_source_class: event['source_class'].to_s}

            closed_key = nil if closed_key == key

            attrs = {state: 'synced',
                     title: event['title'],
                     started_on: event['started_on'],
                     ended_on: event['ended_on'],
                     href: event['url']}

            if (e = content.events.where(key).first)
              next unless e.updated_at < Time.parse(event['updated_at'])
              attrs.delete(:state) if e.state == 'public'
              warn_log "#{__FILE__}:#{__LINE__} #{e.errors.inspect} #{event.inspect}" unless e.update_attributes(attrs)
            else
              e = content.events.build(key.merge attrs)
              e.creator_attributes = { group_id: content.creator.group_id, user_id: content.creator.user_id }
              warn_log "#{__FILE__}:#{__LINE__} #{e.errors.inspect} #{event.inspect}" unless e.save
            end
          end

          if closed_key.present? && (e = content.events.where(closed_key).first)
            e.close!
          end
        else
          warn_log "#{__FILE__}:#{__LINE__} #{res.headers['status']}"
        end
      rescue => e
        warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
      end
    end

    render json: {result: 'OK'}
  end

  def updated_events
    return http_error(405) unless request.get?

    target_content_id = params[:target_content_id].to_i
    target_host = params[:target_host].to_s
    return render(json: []) if target_content_id.zero?

    content = GpCalendar::Content::Event.find_by_id(params[:content_id])
    return render(json: []) unless content.try(:public_node)

    limit = (params[:limit] || 10).to_i
    events = content.public_events.where(will_sync: 'enabled', sync_source_host: nil).reorder(updated_at: :desc).limit(limit)

    settings = GpArticle::Content::Setting.where(name: 'calendar_relation', value: 'enabled')
    contents = settings.map{|s|
                   next unless s.extra_values[:calendar_content_id] == content.id
                   next unless s.content.site == content.site
                   next unless s.content.event_sync?
                   s.content
                 }.compact
    docs = contents.map{|c|
               c.public_docs.where(event_state: 'visible', event_will_sync: 'enabled').reorder(updated_at: :desc).limit(limit)
             }.flatten
    docs.each do |doc|
      event = gp_calendar_doc_to_event(doc: doc, event_content: content)
      events << event if event
    end

    recent_events = events.sort{|a, b| (a.updated_at <=> b.updated_at) * -1 }[0, limit]
    recent_events.map! do |event|
      source_class = event.doc.class.name if event.doc
      source_class ||= event.class.name

      {id: event.id, updated_at: event.updated_at.to_s(:iso8601),
       title: event.title,
       started_on: event.started_on.to_s(:iso8601), ended_on: event.ended_on.to_s(:iso8601),
       url: event.href,
       source_class: source_class}
    end

    render json: recent_events
  end
end
