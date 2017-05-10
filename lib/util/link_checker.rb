class Util::LinkChecker
  def self.check_url(url)
    info_log "Checking #{url}"

    conn = Faraday.new do |b|
      b.use FaradayMiddleware::FollowRedirects, limit: 3
      b.adapter Faraday.default_adapter
    end

    uri = Addressable::URI.parse(url)
    res = conn.head(uri.normalize) do |req|
      req.headers['User-Agent'] = "CMS/#{Zomeki.version}"
      req.options.timeout = 5
      req.options.open_timeout = 5
    end
    { status: res.status, reason: Rack::Utils::HTTP_STATUS_CODES[res.status], result: res.success? }
  rescue => evar
    warn_log evar.message
    { status: nil, reason: evar.message, result: false }
  end
end
