require 'timeout'
class Cms::Script::Publication < Cms::Script::Base
  include Cms::Controller::Layout

  def initialize(params = {})
    super
    initialize_publication
  end

  def self.publishable?
    true
  end

  def initialize_publication
    if @node = params[:node] || Cms::Node.where(id: params[:node_id]).first
      @site = @node.site
    end
    @errors = []
  end

  def publish_page(item, params = {})
    site = params[:site] || @site

    ::Script.current

    if ::Script.options
      path = params[:uri].to_s.sub(/\?.*/, '')
      return false if ::Script.options.is_a?(Array) && !::Script.options.include?(path)
      return false if ::Script.options.is_a?(Regexp) && ::Script.options !~ path
    end

    rendered = render_public_as_string(params[:uri], site: site)
    res = item.publish_page(rendered, path: params[:path], dependent: params[:dependent])
    return false unless res
    #return true if params[:path] !~ /(\/|\.html)$/

    if params[:smart_phone_path].present? && publish_smart_phone_page?(site, item)
      rendered = render_public_as_string(params[:uri], site: site, agent_type: :smart_phone)
      res = item.publish_page(rendered, path: params[:smart_phone_path], dependent: "#{params[:dependent]}_smart_phone")
      return false unless res
    end

    ::Script.success if item.published?

    ## ruby html
    uri = params[:uri]
    if uri =~ /\.html$/
      uri += ".r"
    elsif uri =~ /\/$/
      uri += "index.html.r"
    elsif uri =~ /\/\?/
      uri = uri.gsub(/(\/)(\?)/, '\\1index.html.r\\2')
    elsif uri =~ /\.html\?/
      uri = uri.gsub(/(\.html)(\?)/, '\\1.r\\2')
    else
      return true
    end

    #uri  = (params[:uri] =~ /\.html$/ ? "#{params[:uri]}.r" : "#{params[:uri]}index.html.r")
    path = (params[:path] =~ /\.html$/ ? "#{params[:path]}.r" : "#{params[:path]}index.html.r")
    dep  = params[:dependent] ? "#{params[:dependent]}/ruby" : "ruby"

    ruby = nil
    if item.published?
      ruby = true
    elsif !::File.exist?(path)
      ruby = true
    elsif ::File.stat(path).mtime < Cms::KanaDictionary.dic_mtime
      ruby = true
    end

    if ruby
      begin
        Timeout.timeout(600) do
          rendered = render_public_as_string(uri, site: site)
          item.publish_page(rendered, path: path, dependent: dep)

          #smart_phone_path =
          #  if params[:smart_phone_path].present? && publish_smart_phone_page?(site, item)
          #    params[:smart_phone_path] =~ /\.html$/ ? "#{params[:smart_phone_path]}.r" : "#{params[:smart_phone_path]}index.html.r"
          #  else
          #    nil
          #  end
          #if smart_phone_path
          #  rendered = render_public_as_string(uri, site: site, agent_type: :smart_phone)
          #  item.publish_page(rendered, path: smart_phone_path, dependent: "#{dep}_smart_phone")
          #end
        end
      rescue Timeout::Error => e
        ::Script.error "#{uri} Timeout"
      rescue => e
        ::Script.error "#{uri}\n#{e.message}"
      end
    end

    return res
  rescue => e
    ::Script.error "#{uri}\n#{e.message}"
    error_log e
    error_log e.backtrace.join("\n")
    return false
  end

  def publish_smart_phone_page?(site, item)
    site.publish_for_smart_phone? &&
       (site.spp_all? || (site.spp_only_top? && item.respond_to?(:top_page?) && item.top_page?))
  end

  def page_date(period, start_at, p)
    case period
     when 'monthly'
       (start_at - (p - 1).month)
     when 'weekly'
       (start_at - (p - 1).week)
     else
       nil
     end
  end

  def page_number(period, date, p)
    case period
    when 'monthly'
      (p == 1 ? "" : date.beginning_of_month.strftime('.%Y%m'))
    when 'weekly'
      (p == 1 ? "" : date.beginning_of_week.strftime('.%Y%m%d'))
    else
      (p == 1 ? "" : ".p#{p}")
    end
  end

  def publish_more(item, params = {})
    stopp = nil
    limit = params[:limit] || Zomeki.config.application["cms.publish_more_pages"].to_i rescue 0
    limit = (limit < 1 ? 1 : 1 + limit)
    file  = params[:file] || 'index'
    first = params[:first] || 1
    start_at = params[:start_at] || Date.today
    period = params[:period] || 'simple'

    first.upto(limit) do |p|
      date = page_date(period, start_at, p)
      page = page_number(period, date, p)
      uri  = "#{params[:uri]}#{file}#{page}.html"
      path = "#{params[:path]}#{file}#{page}.html"
      smart_phone_path = (params[:smart_phone_path].present? ? "#{params[:smart_phone_path]}#{file}#{page}.html" : nil)
      dep  = "#{params[:dependent]}#{page}"
      rs = publish_page(item, uri: uri, site: params[:site], path: path, smart_phone_path: smart_phone_path,
                              dependent: dep, smart_phone: params[:smart_phone])
      stopp = p
      if period == 'simple'
        break unless rs
      else
        break if rs.blank? && (params[:end_at].blank? || params[:start_at].blank?)
        break if rs.blank? && params[:end_at] > date
      end
    end

    ## remove over files
    del_first = stopp ? stopp : (limit + 1)
    first = 1
    first.upto(100) do |dp|
      deps = []
      page_num   = ".p#{dp}"
      month_date = page_date('monthly', start_at, dp)
      week_date  = page_date('weekly', start_at, dp)

      month_num  = month_date.beginning_of_month.strftime('.%Y%m')
      week_num   = week_date.beginning_of_week.strftime('.%Y%m%d')

      deps << month_num if (period != 'monthly') || (dp >= del_first && period == 'monthly')
      deps << week_num  if (period != 'weekly')  || (dp >= del_first && period == 'weekly')
      deps << page_num  if (period != 'simple')  || (dp >= del_first && period == 'simple')
      deps = deps.reject(&:blank?)
      next if deps.blank?
      deps = deps.map{|d| "#{params[:dependent]}#{d}" }
      Sys::Publisher.where(publishable: item, dependent: deps).destroy_all
      r_deps = deps.map{|d| "#{d}/ruby" }
      Sys::Publisher.where(publishable: item, dependent: r_deps).destroy_all
    end
  end

  def publish_more_by_period(item, params = {})
    period   = params[:period] || 'monthly'
    file     = params[:file] || 'index'
    start_at = params[:start_at] || Date.today
    start_at = period == 'monthly' ? start_at.beginning_of_month : start_at.beginning_of_week
    target_date = Date.parse(params[:target_date])
    dates = target_dates(period, target_date)

    dates.each do |date|
      p = start_at.to_date == date ? 1 : nil
      page = page_number(period, date, p)
      uri  = "#{params[:uri]}#{file}#{page}.html"
      path = "#{params[:path]}#{file}#{page}.html"
      smart_phone_path = (params[:smart_phone_path].present? ? "#{params[:smart_phone_path]}#{file}#{page}.html" : nil)
      dep  = "#{params[:dependent]}#{page}"
      publish_page(item, uri: uri, site: params[:site], path: path, smart_phone_path: smart_phone_path,
                   dependent: dep, smart_phone: params[:smart_phone])
    end
  end

  def target_dates(period, target_date)
    case period
    when 'monthly'
      [
        target_date.beginning_of_month + 1.month,
        target_date.beginning_of_month,
        target_date.beginning_of_month - 1.month,
        target_date.beginning_of_month - 2.month
      ]
    when 'weekly'
      [
        target_date.beginning_of_week + 1.week,
        target_date.beginning_of_week,
        target_date.beginning_of_week - 1.week,
        target_date.beginning_of_week - 2.week
      ]
    else
      []
    end
  end
end
