class Cms::Public::CommonSslController < ApplicationController
  def index
    path = Core.request_uri.gsub(/^#{Regexp.escape(cms_common_ssl_path)}/, "")
    render_ssl(path, :mobile => Page.mobile?, :smart_phone => request.smart_phone?, :preview => true)
  end

  def render_ssl(path, options = {})
    Core.publish = true unless options[:preview]

    Page.initialize
    Page.site   = options[:site] || Core.site
    Page.uri    = path
    Page.mobile = options[:mobile]
    Page.smart_phone = options[:smart_phone]

    return http_error(404) if Page.site.blank?

    # layouts
    if path =~ /^\/_layouts\/(\d{8})\/([^\/]*)/
      ctl = 'cms/public/layouts'
      act = 'index'
      format = params[:format]
      params[:id] = $1
      params[:file] = File.basename($2, ".*")
    else
      node = Core.search_node(path)
      env  = {}
      env[:method] = :post if request.post?
      opt  = Rails.application.routes.recognize_path(node, env)
      ctl  = opt[:controller]
      act  = opt[:action]

      opt.each {|k,v| params[k] = v }
      #opt[:layout_id] = params[:layout_id] if params[:layout_id]
      opt[:authenticity_token] = params[:authenticity_token] if params[:authenticity_token]

      return redirect_to ::File.join(Page.site.full_uri, path) if node !~ /^\/_public\/survey\/node_forms/
    end

    rendered = Sys::Lib::Controller.dispatch(ctl, act, params: params, base_url: request.base_url,
                                             agent_type: Page.smart_phone? ? :smart_phone : :pc)
    return redirect_to(rendered.redirect_url) if rendered.redirect_url

    response.content_type = rendered.content_type if rendered.respond_to?(:content_type)
    self.response_body = rendered.body
  end
end
