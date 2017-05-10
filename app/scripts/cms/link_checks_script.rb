class Cms::LinkChecksScript < Cms::Script::Base
  def exec
    prepare(::Script.site)
    execute(::Script.site)
  end

  private

  def prepare(site)
    Cms::LinkCheckLog.transaction do
      Cms::LinkCheckLog.where(site_id: site.id).delete_all

      GpArticle::Content::Doc.where(site_id: site.id).each do |content|
        content.docs.public_state.preload(:links).find_each do |doc|
          logs = make_link_check_logs(site, doc, doc.title, doc.links)
          Cms::LinkCheckLog.import(logs)
        end
      end
      Cms::Node::Page.public_state.where(site_id: site.id).preload(:links).find_each do |page|
        logs = make_link_check_logs(site, page, page.title, page.links)
        Cms::LinkCheckLog.import(logs)
      end
    end
  end

  def make_link_check_logs(site, item, title, links)
    links.each_with_object([]) do |link, logs|
      url = link.make_absolute_url(site)
      next unless url
      logs << Cms::LinkCheckLog.new(site_id: site.id,
                                    link_checkable: item,
                                    title: title,
                                    body: link.body,
                                    url: url,
                                    checked: false)
    end
  end

  def execute(site)
    regexp = site.link_check_exclusion_regexp

    logs = Cms::LinkCheckLog.where(site_id: site.id, checked: false)

    ::Script.total logs.count

    logs.find_each do |log|
      ::Script.progress(log) do
        if regexp && regexp.match(log.url)
          log.reason = 'リンチェック対象外'
          log.result_state = 'skip'
        else
          res = Util::LinkChecker.check_url(log.url)
          log.status = res[:status]
          log.reason = res[:reason]
          log.result = res[:result]
          log.result_state = res[:result] ? 'success' : 'failure'
        end
        log.checked = true
        log.checked_at = Time.now
        log.save
      end
    end
  end
end
