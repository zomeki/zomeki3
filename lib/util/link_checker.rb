class Util::LinkChecker
  def self.check(site)
    plan_check(site)
    execute(site)
  end

  def self.plan_check(site)
    Cms::LinkCheckLog.where(site_id: site.id).delete_all

    GpArticle::Content::Doc.where(site_id: site.id).each do |content|
      logs = []
      content.docs.public_state.preload(:links).find_each do |doc|
        doc.links.each do |link|
          next unless url = link.make_absolute_url(site)
          logs << Cms::LinkCheckLog.new(site_id: site.id, link_checkable: doc, title: doc.title, body: link.body, url: url, checked: false)
        end
      end
      Cms::LinkCheckLog.import(logs)
    end

    Cms::Node::Page.public_state.where(site_id: site.id).preload(:links).find_each do |page|
      logs = []
      page.links.each do |link|
        next unless url = link.make_absolute_url(site)
        logs << Cms::LinkCheckLog.new(site_id: site.id, link_checkable: page, title: page.title, body: link.body, url: url, checked: false)
      end
      Cms::LinkCheckLog.import(logs)
    end
  end

  def self.execute(site)
    Cms::LinkCheckLog.where(site_id: site.id, checked: false).order(:id).find_each do |log|
      res = Util::LinkChecker.check_url(log.url)
      log.status = res[:status]
      log.reason = res[:reason]
      log.result = res[:result]
      log.checked = true
      log.save
    end
  end

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
