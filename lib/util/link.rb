class Util::Link
  class << self
    def extract_links(html)
      return [] if html.blank?

      doc = Nokogiri::HTML.fragment(html)
      links = doc.css('a[@href]')
                 .map { |a| { body: a.text, url: a.attribute('href').value } }
      links.select do |link|
        uri = Addressable::URI.parse(link[:url]) rescue nil
        uri && (uri.relative? || uri.scheme.to_s.downcase.in?(%w(http https)))
      end
    rescue => evar
      warn_log evar.message
      return []
    end

    def include_pdf_link?(html)
      links = extract_links(html)
      links.any? { |link| link[:url] =~ /\.pdf$/i }
    end
  end
end
