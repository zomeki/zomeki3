class GpArticle::ArchivesScript < Cms::Script::Publication
  def publish
    all_days = []
    beginning_of_month = Date.new(2013, 1, 1)
    this_bom = Date.today.beginning_of_month
    until (this_bom < beginning_of_month) do
      all_days << beginning_of_month
      beginning_of_month += 1.month
    end

    days = @node.content.public_docs.group("TO_CHAR(display_published_at, 'YYYYMM01')")
                                    .pluck("TO_CHAR(display_published_at, 'YYYYMM01')")
                                    .map{|d| Time.parse(d).beginning_of_month.to_date }
    # Not exist pages
    (all_days - days).each do |day|
      path = "#{@node.public_path}#{day.strftime('%Y/%m')}/"
      smart_phone_path = "#{@node.public_smart_phone_path}#{day.strftime('%Y/%m')}/"
      FileUtils.rm_rf([path, smart_phone_path])
    end

    # Month pages
    days.each do |day|
      slash = day.strftime('%Y/%m')
      underscore = day.strftime('%Y_%m')

      uri = "#{@node.public_uri}#{slash}/"
      path = "#{@node.public_path}#{slash}/"
      smart_phone_path = "#{@node.public_smart_phone_path}#{slash}/"
      dependent = underscore

      publish_page(@node, uri: uri, site: @node.site,
                          path: path, smart_phone_path: smart_phone_path,
                          dependent: dependent)
    end

    days.uniq!{|d| d.strftime('%Y') }

    # Year pages
    days.each do |day|
      year = day.strftime('%Y')

      uri = "#{@node.public_uri}#{year}/"
      path = "#{@node.public_path}#{year}/"
      smart_phone_path = "#{@node.public_smart_phone_path}#{year}/"
      dependent = year

      publish_page(@node, uri: uri, site: @node.site,
                          path: path, smart_phone_path: smart_phone_path,
                          dependent: dependent)
    end
  end
end
