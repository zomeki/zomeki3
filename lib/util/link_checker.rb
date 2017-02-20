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

    require 'httpclient'
    client = HTTPClient.new

    res = client.head(url)
    if res.redirect?
      3.times do
        break unless res.redirect?

        uri = URI.parse(res.headers['Location'] || res.headers['location'])
        next_url = unless uri.absolute?
                     path = uri.path

                     u = URI.parse(url)
                     if path =~ /^\//
                       u.path = path
                     else
                       u.path = '/' if u.path.blank?
                       u.path.sub!(/[^\/]+$/, '')
                       u.path.concat(path)
                     end
                     u.to_s
                   else
                     uri.to_s
                   end

        res = client.head(next_url)
      end
    end
    {status: res.status, reason: res.reason, result: res.ok?}
  rescue => evar
    warn_log evar.message
    {status: nil, reason: evar.message, result: false}
  end
end
