class GpCalendar::Public::Node::BaseController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = GpCalendar::Content::Event.find_by(id: @node.content.id)
    return http_error(404) unless @content

    @today = Date.today
    @min_date = 1.year.ago(@today.beginning_of_month)
    @max_date = 11.months.since(@today.beginning_of_month)

    return http_error(404) unless validate_date

    # These params are used in pieces
    params[:gp_calendar_event_date]     = @date
    params[:gp_calendar_event_min_date] = @min_date
    params[:gp_calendar_event_max_date] = @max_date
  end

  private

  def validate_date
    @year_only = params[:year].to_i.nonzero? && params[:month].to_i.zero?

    @month = params[:month].to_i
    @month = @today.month if @month.zero?
    return false unless @month.between?(1, 12)

    @year = params[:year].to_i
    @year = @today.year if @year.zero?
    return false unless @year.between?(1900, 2100)

    @date = Date.new(@year, @month, 1)
    if @year_only
      @date.year.between?(@min_date.year, @max_date.year)
    else
      @date.between?(@min_date, @max_date)
    end
  end

  def event_docs(start_date, end_date, categories = nil)
    doc_contents = Cms::ContentSetting.where(name: 'calendar_relation', value: 'enabled')
                                      .map{|cs| cs.content if cs.extra_values[:calendar_content_id] == @content.id }.compact
    doc_contents.select! {|dc| dc.site == Page.site }
    return [] if doc_contents.empty?

    doc_contents.map {|dc|
      case dc.model
      when 'GpArticle::Doc'
        dc = GpArticle::Content::Doc.find(dc.id)
        dc.public_docs.where(event_state: 'visible').event_scheduled_between(start_date, end_date, categories)
          .preload_assocs(:public_node_ancestors_assocs, :event_categories, :files)
      else
        []
      end
    }.flatten
  end

  def merge_docs_into_events(docs, events)
    docs.each do |doc|
      options = view_context.link_to_doc_options(doc)
      doc_uri = unless options.kind_of?(Array)
                  doc.public_full_uri
                else
                  if (uri = options[0].to_s)[0] == '/'
                    "#{doc.content.site.full_uri}#{uri[1..-1]}"
                  else
                    uri
                  end
                end

      event = GpCalendar::Event.new(
        title: doc.title, href: doc_uri, target: '_self',
        started_on: doc.event_started_on, ended_on: doc.event_ended_on,
        description: doc.summary, content: @content, will_sync: 'disabled'
      )
      event.categories = doc.event_categories
      event.files = doc.files
      event.doc = doc

      events << event
    end
    events.sort! {|a, b| a.started_on <=> b.started_on }
  end

  def find_category_by_specified_path(path)
    return nil unless path.kind_of?(String)
    category_type_name, category_path = path.split('/', 2)
    category_type = @content.category_types.find_by(name: category_type_name)
    return nil unless category_type
    category_type.find_category_by_path_from_root_category(category_path)
  end

  def filter_events_by_specified_category(events)
    path = params[:category] ? params[:category] : params[:escaped_category].to_s.gsub('@', '/')
    if (category = find_category_by_specified_path(path))
      @events.reject! do |e|
        next true unless e.respond_to?(:category_ids)
        (e.category_ids & category.public_descendants.map(&:id)).empty?
      end
    end
  end
end
