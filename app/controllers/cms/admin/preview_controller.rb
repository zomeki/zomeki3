class Cms::Admin::PreviewController < Cms::Controller::Admin::Base
  after_action :replace_preview_data

  def index
    path = Core.request_uri.gsub(/^#{Regexp.escape(cms_preview_path)}/, "")

    render_preview(path, :mobile => Page.mobile?, :preview => true)
  end

  def render_preview(path, options = {})
    Core.publish = true unless options[:preview]
    mode = Core.set_mode('preview')

    Page.initialize
    Page.site   = options[:site] || Core.site
    Page.uri    = path
    Page.mobile = options[:mobile]

    if path =~ /^\/_files\//
      ## _files
      file_path = path.gsub(/^\/_files\//, '')
      format    = ::File.extname(file_path)

      opt  = {
        :path   => file_path.gsub(format, ''),
        :format => format.gsub(/^\./, '')
      }
      ctl  = "cms/public/files"
      act  = "down"

    elsif path =~ /^\/_themes\//
      ## _themes
      root      = "#{Core.site.public_path}/_themes"
      full_path = "#{root}/#{path.gsub(/^\/_themes\//, '')}"
      base_uri  = ["#{Core.site.public_path}/", "/"]

      stylesheet = Cms::Stylesheet.find(full_path, :root => root, :base_uri => base_uri)
      return http_error(404) unless ::File.exist?(full_path)
      return send_file(full_path, :type => stylesheet.mime_type, :filename => stylesheet.name, :disposition => 'inline')

    else
      node = Core.search_node(path)
      env  = {}
      opt  = _routes.recognize_path(node, env)
      ctl  = opt[:controller]
      act  = opt[:action]
    end

    opt.each {|k,v| params[k] = v }
    #opt[:layout_id] = params[:layout_id] if params[:layout_id]
    #opt[:authenticity_token] = params[:authenticity_token] if params[:authenticity_token]

    component_response = render_component :controller => ctl, :action => act, :params => params
    response.content_type = component_response.content_type if component_response.respond_to?(:content_type)
  end

protected
  def replace_preview_data
    return if response.content_type != 'text/html' && response.content_type != 'application/xhtml+xml'
    return if response.body.class != String

    public_uri = URI.parse(Page.site.full_uri)
    public_uri.path = '/'

    if Core.script_uri
      admin_uri = Addressable::URI.parse(Core.script_uri)
      admin_uri.path = '/'
    else
      admin_uri = Cms::SiteSetting::AdminProtocol.core_domain Page.site, :freeze_protocol => true
    end

    mobile   = Page.mobile? ? 'm' : ''
    base_uri = "#{admin_uri}_preview/#{format('%04d', Page.site.id)}#{mobile}"

    self.response_body = response.body.gsub(/ (href|src)="\/[^"]*?"[^>]*?>/i) do |m|
      if m =~ /(href|src)="(\/_common\/|\/\/)/
        m
      else
        m.gsub(/^( href="| src=")(\/[^"]*?)("[^>]*?>)/i, '\\1' + base_uri + '\\2\\3')
      end
    end

    ## preview mark
    html = render_to_string(partial: 'cms/admin/preview/preview_mark')
    self.response_body = response.body.gsub(/(<body[^>]*?>)/i, '\\1' + html)

    ## host
    doc = Nokogiri::HTML.parse(response.body)
    unless (a_tags = doc.css(%Q!a[href^="#{public_uri}"]!)).empty?
      a_tags.each do |a_tag|
        a_tag.set_attribute('href', a_tag.attribute('href').to_s.sub(public_uri.to_s, admin_uri.to_s))
      end
    end
    unless (img_tags = doc.css(%Q!img[src^="#{public_uri}"]!)).empty?
      img_tags.each do |img_tag|
        img_tag.set_attribute('src', img_tag.attribute('src').to_s.sub(public_uri.to_s, admin_uri.to_s))
      end
    end
    self.response_body = doc.to_s

  end
end
