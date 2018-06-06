class Util::Http::Request
  class << self
    def head(url, options = {})
      rescue_error do
        uri = Addressable::URI.parse(url).normalize
        return Faraday::Response.new if invalid_uri?(uri)

        Faraday.head(uri) do |req|
          set_request_from_options(req, options)
        end
      end
    end

    def get(url, options = {})
      rescue_error do
        uri = Addressable::URI.parse(url).normalize
        return Faraday::Response.new if invalid_uri?(uri)

        Faraday.get(uri) do |req|
          set_request_from_options(req, options)
        end
      end
    end

    def post(url, body, options = {})
      rescue_error do
        uri = Addressable::URI.parse(url).normalize
        return Faraday::Response.new if invalid_uri?(uri)

        Faraday.post(uri, body) do |req|
          set_request_from_options(req, options)
        end
      end
    end

    private

    def invalid_uri?(uri)
      uri.scheme.blank? || uri.host.blank?
    end

    def rescue_error
      yield
    rescue Faraday::TimeoutError => e
      Faraday::Response.new(status: 408)
    rescue => e
      warn_log e
      Faraday::Response.new
    end

    def set_request_from_options(req, options)
      req.headers = options[:header] if options[:header]
      req.headers['User-Agent'] ||= "Mozilla/5.0 (CMS/#{Zomeki.version})"
      req.options.timeout = options[:timeout] || 30
      req.options.open_timeout = options[:timeout] || 30
    end
  end
end
