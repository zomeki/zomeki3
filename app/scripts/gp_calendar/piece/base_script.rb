class GpCalendar::Piece::BaseScript < GpCalendar::Node::BaseScript
  def publish_with_months
    min_date = get_min_date
    max_date = get_max_date(min_date)

    prms = (min_date.year..max_date.year).to_a.map { |y| "#{y}/" }
    prms += (min_date..max_date).to_a.select { |d| d.day == 1 }.map { |d| d.strftime('%Y/%m/') }

    uri = @piece.public_uri.to_s
    path = @piece.public_path.to_s
    smart_phone_path = @piece.public_smart_phone_path.to_s

    publish_page(@piece, uri: @piece.public_uri,
                         path: @piece.public_path,
                         smart_phone_path: @piece.public_smart_phone_path)
    prms.each do |prm|
      publish_page(@piece, uri: "#{uri}#{prm}",
                           path: "#{path}#{prm}",
                           smart_phone_path: "#{smart_phone_path}#{prm}",
                           dependent: prm)
    end
  end
end
