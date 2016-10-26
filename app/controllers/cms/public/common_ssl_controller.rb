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
      opt  = _routes.recognize_path(node, env)
      ctl  = opt[:controller]
      act  = opt[:action]

      opt.each {|k,v| params[k] = v }
      #opt[:layout_id] = params[:layout_id] if params[:layout_id]
      opt[:authenticity_token] = params[:authenticity_token] if params[:authenticity_token]

      return redirect_to ::File.join(Page.site.full_uri, path) if node !~ /^\/_public\/survey\/node_forms/
    end

    component_response = render_component :controller => ctl, :action => act, :params => params, :jpmobile => (Page.smart_phone? ? envs_to_request_as_smart_phone : nil)
    response.content_type = component_response.content_type unless component_response.class == String
  end
end
