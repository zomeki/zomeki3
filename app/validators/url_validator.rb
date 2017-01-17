class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attr, value)
    return if value.blank?

    begin
      uri = URI.parse(value)
    rescue URI::InvalidURIError => e
      record.errors.add(attr, :invalid_url)
      return
    end

    if uri.scheme.blank? || uri.host.blank? || uri.host.include?('_')
      record.errors.add(attr, :invalid_url)
    end
  end
end
