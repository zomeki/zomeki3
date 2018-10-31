class Cms::Admin::PreviewController < Cms::Controller::Admin::Base
  protect_from_forgery except: :index

  after_action :add_preview_header, if: -> { preview_as_html? && !request.xhr? }
  after_action :convert_for_talk_order, if: -> { preview_as_html? && params[:talk_order] }
  after_action :replace_links_for_preview, if: -> { preview_as_html? }

  def pre_dispatch
    if params[:commit]
      site = params[:site].scan(/^\d+/).flatten.first
      site << params[:preview_terminal]
      if params[:preview_at].present?
        preview_at = Time.parse(params[:preview_at]) rescue nil
        site << "_#{preview_at.strftime('%Y%m%d%H%M')}" if preview_at
      end
      url = "/_preview/#{site}/#{params[:path]}"
      url << "?#{params[:query_string]}" if params[:query_string].present?
      redirect_to url
    end
  end

  def index
    path = Core.request_uri.gsub(/^#{Regexp.escape(cms_preview_path)}/, "")

    render_preview(path, mobile: Page.mobile?, smart_phone: Page.smart_phone?, preview_at: Page.preview_at)
  end

  def render_preview(path, options = {})
    Page.initialize
    Page.site   = Core.site
    Page.uri    = path
    Page.mobile = options[:mobile]
    Page.smart_phone = options[:smart_phone]
    Page.preview_at = options[:preview_at]

    node = Core.search_node(path)
    opt  = Rails.application.routes.recognize_path(node)

    if opt[:controller] == 'cms/public/exception'
      path += 'index.html' if path.end_with?('/')
      file_path = File.join(Page.site.public_path, path)
      if File.exist?(file_path) && File.ftype(file_path) == 'file'
        return send_file(file_path, type: ::Storage.mime_type(path), filename: ::File.basename(path), disposition: 'inline')
      end
    end

    ctl  = opt[:controller]
    act  = opt[:action]

    opt.each {|k,v| params[k] = v }
    #opt[:layout_id] = params[:layout_id] if params[:layout_id]
    #opt[:authenticity_token] = params[:authenticity_token] if params[:authenticity_token]

    rendered = Sys::Lib::Controller.dispatch(ctl, act, request: request, params: params, agent_type: Page.agent_type)
    return redirect_to(rendered.redirect_url) if rendered.redirect_url

    response.content_type = rendered.content_type if rendered.respond_to?(:content_type)
    self.response_body = rendered.body
  end

private

  def preview_as_html?
    response.content_type.in?(%w(text/html application/xhtml+xml))
  end

  def add_preview_header
    return if params[:inlining] == 'true'

    html = render_to_string(partial: 'cms/admin/preview/header', formats: [:html])
    response.body = response.body.to_s.sub(/(<\/head>)/i) { html + $1.html_safe }

    html = render_to_string(partial: 'cms/admin/preview/mark', formats: [:html])
    response.body = response.body.to_s.sub(/(<body[^>]*?>)/i) { $1.html_safe + html }
  end

  def convert_for_talk_order
    nokogiri = Page.mobile? ? Nokogiri::XML : Nokogiri::HTML
    doc = nokogiri.parse(response.body, nil, 'utf-8')
    doc = Cms::Lib::Navi::Jtalk.filter_html_tags(doc)
    return unless doc

    doc.css('*').each do |node|
      node.remove_attribute('class')
      node.remove_attribute('style')
    end

    response.body = Page.mobile? ? doc.to_xhtml : doc.to_html
  end

  def replace_links_for_preview
    return if response.body.class != String

    public_uri = public_uri_for_replace
    admin_uri = admin_uri_for_replace
    preview_uri = "#{admin_uri}_preview/#{format('%04d', Page.site.id)}#{Page.preview_terminal}"
    preview_uri << "_#{Page.preview_at.strftime("%Y%m%d%H%M")}" if Page.preview_at

    doc = Page.mobile? ?
      Nokogiri::XML(response.body, nil, 'utf-8') :
      Nokogiri::HTML(response.body, nil, 'utf-8')

    %w(href src).each do |attr|
      doc.css(%Q![#{attr}]!).each do |node|
        next if node[attr].blank?
        uri = Addressable::URI.parse(node[attr]) rescue nil
        next if uri.nil?
        if uri.relative? && uri.path !~ %r|/_common/| && node[attr] !~ %r|\A#| && node[attr] !~ %r|\A\/\/| && node[attr] =~ %r|\A\/|
          node[attr] = "#{preview_uri}#{node[attr]}"
        end
      end
    end

    [%w(a href), %w(img src)].each do |tag, attr|
      doc.css(%Q!#{tag}[#{attr}^="#{public_uri}"]!).each do |node|
        next if node[attr].blank?
        node[attr] = node[attr].sub(public_uri) { admin_uri }
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
