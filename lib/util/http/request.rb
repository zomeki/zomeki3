class Util::Http::Request
  def self.head(url, options = {})
    uri = Addressable::URI.parse(url).normalize
    rescue_timeout do
      Faraday.head(uri) do |req|
        set_request_from_options(req, options)
      end
    end
  end

  def self.get(url, options = {})
    uri = Addressable::URI.parse(url).normalize
    rescue_timeout do
      Faraday.get(uri) do |req|
        set_request_from_options(req, options)
      end
    end
  end

  def self.post(url, body, options = {})
    uri = Addressable::URI.parse(url).normalize
    rescue_timeout do
      Faraday.post(uri, body) do |req|
        set_request_from_options(req, options)
      end
    end
  end

  private

  def self.rescue_timeout
    yield
  rescue Faraday::TimeoutError => e
    Faraday::Response.new(status: 408)
  rescue => e
    warn_log e
    Faraday::Response.new
  end

  def self.set_request_from_options(req, options)
    req.headers = options[:header] if options[:header]
    req.headers['User-Agent'] ||= "Mozilla/5.0 (CMS/#{Zomeki.version})"
    req.options.timeout = options[:timeout] || 30
    req.options.open_timeout = options[:timeout] || 30
  end
end
