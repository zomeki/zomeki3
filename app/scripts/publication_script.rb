require 'timeout'
class PublicationScript < ParametersScript
  def initialize(params = {})
    super
    initialize_publication
  end

  def initialize_publication
    @node = params[:node] || Cms::Node.where(id: params[:node_id]).first
    @site = @node.site if @node
  end

  def publish_page(item, options = {})
    site = options[:site] || @site

    ::Script.current

    rendered = Cms::RenderService.new(site).render_public(options[:uri])
    return false unless item.publish_page(rendered, path: options[:path], dependent: options[:dependent])

    if options[:smart_phone_path].present? && site.publish_for_smart_phone?(item)
      dep = [options[:dependent].presence, "smart_phone"].compact.join('_')
      rendered_sp = Cms::RenderService.new(site).render_public(options[:uri], agent_type: :smart_phone)
      return false unless item.publish_page(rendered_sp, path: options[:smart_phone_path], dependent: dep)
    end

    ::Script.success if item.published?

    if options[:path] =~ /(\.html|\/)$/ && site.use_kana?
      path = (options[:path] =~ /\.html$/ ? "#{options[:path]}.r" : "#{options[:path]}index.html.r")
      dep  = [options[:dependent].presence, "ruby"].compact.join('/')

      if item.published? || !::File.exist?(path) || ::File.stat(path).mtime < Cms::KanaDictionary.dic_mtime(site.id)
        begin
          Timeout.timeout(600) do
            rendered = Cms::Lib::Navi::Kana.convert(rendered, site.id)
            item.publish_page(rendered, path: path, dependent: dep)
          end
        rescue => e
          ::Script.error "#{path}\n#{e.message}"
        end
      end
    end

    return true
  rescue => e
    ::Script.error "#{uri}\n#{e.message}"
    error_log e
    return false
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

    overall_deps = overall_dependents(dependent)
    needless_deps = (overall_deps - published_deps).flat_map { |dep| related_dependents(dep) } 
    item.publishers.where(dependent: needless_deps).destroy_all
  end

  def related_dependents(dep)
    if dep.present?
      [dep, "#{dep}/ruby", "#{dep}/talk", "#{dep}_smart_phone"]
    else
      [dep, "ruby", "talk", "smart_phone"]
    end
  end

  def overall_dependents(dependent)
    page_range = 2..200
    date_range = (Date.today - 5.years)..(Date.today + 1.years)

    paginations = page_range.map { |p| simple_pagination(p) }
    paginations += date_range.select { |d| d.wday == 1 }.map { |d| weekly_pagination(d) }
    paginations += date_range.select { |d| d.day == 1 }.map { |d| monthly_pagination(d) }
    paginations.map { |p| "#{dependent}#{p}" }
  end
end
