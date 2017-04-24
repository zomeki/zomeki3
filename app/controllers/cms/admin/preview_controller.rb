class Cms::Admin::PreviewController < Cms::Controller::Admin::Base
  after_action :add_preview_mark, if: :preview_as_html?
  after_action :replace_links_for_preview, if: :preview_as_html?

  def index
    path = Core.request_uri.gsub(/^#{Regexp.escape(cms_preview_path)}/, "")

    render_preview(path, mobile: Page.mobile?, smart_phone: Page.smart_phone?, preview: true)
  end

  def render_preview(path, options = {})
    Core.publish = true unless options[:preview]
    mode = Core.set_mode('preview')

    Page.initialize
    Page.site   = options[:site] || Core.site
    Page.uri    = path
    Page.mobile = options[:mobile]
    Page.smart_phone = options[:smart_phone]

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
      entry = Sys::Storage::Entry.from_path("#{Core.site.public_path}#{path}")
      return http_error(404) unless entry.exists?
      return send_file(entry.path, type: entry.mime_type, filename: entry.name, disposition: 'inline')

    else
      node = Core.search_node(path)
      opt  = Rails.application.routes.recognize_path(node)

      if opt[:controller] == 'exception'
        file_path = File.join(Page.site.public_path, path)
        if File.exist?(file_path) && File.ftype(file_path) == 'file'
          return send_file(file_path, type: ::Storage.mime_type(path), filename: ::File.basename(path), disposition: 'inline')
        end
      end

      ctl  = opt[:controller]
      act  = opt[:action]
    end

    opt.each {|k,v| params[k] = v }
    #opt[:layout_id] = params[:layout_id] if params[:layout_id]
    #opt[:authenticity_token] = params[:authenticity_token] if params[:authenticity_token]

    rendered = Sys::Lib::Controller.dispatch(ctl, act, params: params, base_url: request.base_url)
    return redirect_to(rendered.redirect_url) if rendered.redirect_url

    response.content_type = rendered.content_type if rendered.respond_to?(:content_type)
    self.response_body = rendered.body
  end

private

  def preview_as_html?
    response.content_type.in?(%w(text/html application/xhtml+xml))
  end

  def add_preview_mark
    html = render_to_string(partial: 'cms/admin/preview/preview_mark', formats: [:html])
    response.body = response.body.to_s.sub(/(<body[^>]*?>)/i, '\\1' + html)
  end

  def replace_links_for_preview
    return if response.body.class != String

    public_uri = public_uri_for_replace
    admin_uri = admin_uri_for_replace
    preview_uri = "#{admin_uri}_preview/#{format('%04d', Page.site.id)}#{Page.preview_terminal}"

    doc = Page.mobile? ?
      Nokogiri::XML(response.body, nil, 'utf-8') :
      Nokogiri::HTML(response.body, nil, 'utf-8')

    %w(href src).each do |attr|
      doc.css(%Q![#{attr}]!).each do |node|
        next if node[attr].blank?
        uri = Addressable::URI.parse(node[attr])
        if uri.relative? && uri.path !~ %r|/_common/| && node[attr] !~ %r|\A#| && node[attr] !~ %r|\A\/\/| && node[attr] =~ %r|\A\/|
          node[attr] = "#{preview_uri}#{node[attr]}"
        end
      end
    end

    [%w(a href), %w(img src)].each do |tag, attr|
      doc.css(%Q!#{tag}[#{attr}^="#{public_uri}"]!).each do |node|
        next if node[attr].blank?
        node[attr] = node[attr].sub(public_uri, admin_uri)
      end
    end

    self.response_body = Page.mobile? ?
      doc.to_xhtml :
      doc.to_html
  end

  def public_uri_for_replace
    uri = Addressable::URI.parse(Page.site.full_uri)
    uri.path = '/'
    uri.to_s
  end

  def admin_uri_for_replace
    uri = Addressable::URI.parse(Core.script_uri)
    uri.path = '/'
    uri.query = uri.fragment = nil
    uri.to_s
  end
end
