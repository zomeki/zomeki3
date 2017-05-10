class GpCalendar::BaseScript < Cms::Script::Publication
  private

  def get_min_date
    if params[:target_min_date].present?
      Date.parse(params[:target_min_date])
    else
      1.year.ago(Date.today.beginning_of_month).to_date
    end
  end

  def get_max_date(min_date)
    if params[:target_max_date].present?
      Date.parse(params[:target_max_date])
    else
      2.years.since(min_date).to_date
    end
  end

  def publish_with_months
    min_date = get_min_date
    max_date = get_max_date(min_date)

    prms = (min_date.year..max_date.year).to_a.map { |y| "#{y}/" }
    prms += (min_date..max_date).to_a.select { |d| d.day == 1 }.map { |d| d.strftime('%Y/%m/') }

    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s

    files = @node.content.public_category_types.map { |ct|
      ct.public_categories.map { |c| "index_#{c.category_type.name}@#{c.path_from_root_category.gsub('/', '@')}" }
    }.flatten

    publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: uri)
    files.each do |file|
      publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: "#{uri}#{file}", file: file)
    end
    prms.each do |prm|
      publish_more(@node, uri: "#{uri}#{prm}", path: "#{path}#{prm}", smart_phone_path: "#{smart_phone_path}#{prm}",
                          dependent: "#{uri}#{prm}")
      files.each do |file|
        publish_more(@node, uri: "#{uri}#{prm}", path: "#{path}#{prm}", smart_phone_path: "#{smart_phone_path}#{prm}",
                            dependent: "#{uri}#{prm}#{file}", file: file)
      end
    end

    events_table = GpCalendar::Event.arel_table
    events = @node.content.public_events.where(events_table[:started_on].lt(max_date)
                                               .and(events_table[:ended_on].gteq(min_date)))
    events.each(&:publish_files)
  end

  def publish_without_months
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s

    publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: uri)
  end
end
