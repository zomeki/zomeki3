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
    smart_phone_path =
      if params[:smart_phone_path].present? && publish_smart_phone_page?(site, item)
        params[:smart_phone_path] =~ /\.html$/ ? "#{params[:smart_phone_path]}.r" : "#{params[:smart_phone_path]}index.html.r"
      else
        nil
      end
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
          if smart_phone_path
            rendered = render_public_as_string(uri, site: site, agent_type: :smart_phone)
            item.publish_page(rendered, path: smart_phone_path, dependent: "#{dep}_smart_phone")
          end
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

  def simple_pages(first, limit)
    first.upto(limit).map do |p|
      { id: p, pagination: p == 1 ? "" : simple_pagination(p) }
    end
  end

  def simple_pagination(p)
    ".p#{p}"
  end

  def weekly_pages(page_dates)
    page_dates.map.with_index(1) do |date, p|
      { id: date, pagination: p == 1 ? "" : weekly_pagination(date) }
    end
  end

  def weekly_pagination(date)
    date.beginning_of_week.strftime('.%Y%m%d')
  end

  def monthly_pages(page_dates)
    page_dates.map.with_index(1) do |date, p|
      { id: date, pagination: p == 1 ? "" : monthly_pagination(date) }
    end
  end

  def monthly_pagination(date)
    date.beginning_of_month.strftime('.%Y%m')
  end

  def default_limit_from_config
    Zomeki.config.application["cms.publish_more_pages"].to_i
  end

  def publish_more(item, uri:, path:, smart_phone_path: nil, dependent: nil, file: 'index',
                         first: 1, limit: default_limit_from_config, page_style: 'simple')
    limit = (limit < 1 ? 1 : 1 + limit)

    pages = simple_pages(first, limit)
    pages.each do |page|
      p_uri  = "#{uri}#{file}#{page[:pagination]}.html"
      p_path = "#{path}#{file}#{page[:pagination]}.html"
      p_smart_phone_path = (smart_phone_path.present? ? "#{smart_phone_path}#{file}#{page[:pagination]}.html" : nil)
      p_dep  = "#{dependent}#{page[:pagination]}"
      rs = publish_page(item, uri: p_uri, path: p_path, smart_phone_path: p_smart_phone_path, dependent: p_dep)
      break unless rs

      page[:published] = true
    end

    ## remove over files
    clean_publshers(item, pages, dependent: dependent)
  end

  def publish_more_dates(item, uri:, path:, smart_phone_path: nil, dependent: nil, file: 'index',
                               page_style: 'monthly', page_dates:)
    pages =
      case page_style.to_sym
      when :weekly
        weekly_pages(page_dates)
      when :monthly
        monthly_pages(page_dates)
      else
        raise 'invalid page page_style option'
      end

    pages.each do |page|
      p_uri  = "#{uri}#{file}#{page[:pagination]}.html"
      p_path = "#{path}#{file}#{page[:pagination]}.html"
      p_smart_phone_path = (smart_phone_path.present? ? "#{smart_phone_path}#{file}#{page[:pagination]}.html" : nil)
      p_dep  = "#{dependent}#{page[:pagination]}"
      rs = publish_page(item, uri: p_uri, path: p_path, smart_phone_path: p_smart_phone_path, dependent: p_dep)

      page[:published] = true if rs
    end

    ## remove over files
    clean_publshers(item, pages, dependent: dependent)
  end

  def publish_target_dates(item, uri:, path:, smart_phone_path: nil, dependent: nil, file: 'index',
                                 page_style: 'monthly', first_date:, target_dates: [])
    target_dates.each do |date|
      pagination =
        case page_style.to_sym
        when :weekly
          date == first_date.beginning_of_week ? '' : weekly_pagination(date)
        when :monthly
          date == first_date.beginning_of_month ? '' : monthly_pagination(date)
        end
      p_uri  = "#{uri}#{file}#{pagination}.html"
      p_path = "#{path}#{file}#{pagination}.html"
      p_smart_phone_path = (smart_phone_path.present? ? "#{smart_phone_path}#{file}#{pagination}.html" : nil)
      p_dep  = "#{dependent}#{pagination}"
      rs = publish_page(item, uri: p_uri, path: p_path, smart_phone_path: p_smart_phone_path, dependent: p_dep)

      unless rs
        item.publishers.where(dependent: related_dependents(p_dep)).destroy_all
      end
    end
  end

  def clean_publshers(item, pages, dependent: nil)
    published_deps = pages.select { |page| page[:published] }
                          .map { |page| "#{dependent}#{page[:pagination]}" }

    overall_deps = overall_dependents(:simple, dependent) +
                   overall_dependents(:weekly, dependent) +
                   overall_dependents(:monthly, dependent)

    needless_deps = (overall_deps - published_deps).flat_map { |dep| related_dependents(dep) } 
    item.publishers.where(dependent: needless_deps).destroy_all
  end

  def related_dependents(dep)
    [dep, "#{dep}/ruby", "#{dep}_smart_phone", "#{dep}/ruby_smart_phone"]
  end

  def overall_dependents(page_style, dependent)
    paginations =
      case page_style.to_sym
      when :simple
        2.upto(200).map { |p| simple_pagination(p) }
      when :weekly
        dates = (Date.today - 5.years) .. (Date.today + 1.years)
        dates.select { |d| d.wday == 1 }.map { |d| weekly_pagination(d) }
      when :monthly
        dates = (Date.today - 5.years) .. (Date.today + 1.years)
        dates.select { |d| d.day == 1 }.map { |d| monthly_pagination(d) }
      end
    paginations.map { |p| "#{dependent}#{p}" }
  end
end
