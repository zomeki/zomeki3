class Cms::Controller::Public::Base < Sys::Controller::Public::Base
  include Cms::Controller::Layout

  rescue_from ActiveRecord::RecordNotFound, with: -> { http_error(404) }

  before_action :initialize_params
  before_action :check_mobile_access
  after_action :render_public_variables
  after_action :render_public_layout

  def initialize_params
    if m = Page.uri.match(/\.p(\d+)\.html(\.r)?\z/)
      page = m[1].to_i
      params[:page] = page if page > 0
    end
    if d = Page.uri.match(/\.(\d+)\.html(\.r)?\z/)
      date = d[1].to_s
      params[:date] = date
    end
  end

  def pre_dispatch
    ## each processes before dispatch
  end

  def render_public_variables
  end

  private

  def check_mobile_access
    http_error(404) if request.mobile? && !Page.site.use_mobile_feature?
  end

  def http_error(status, message = nil)
    message = default_http_error_message(status, message)

    if request.mobile?
      file_status = "#{status}_mobile.html"
      file_500 = "500_mobile.html"
    else
      file_status = "#{status}.html"
      file_500 = "500.html"
    end

    html = if Page.site && FileTest.exist?("#{Page.site.public_path}/#{file_status}")
             ::File.read("#{Page.site.public_path}/#{file_status}")
           elsif Page.site && (node = Page.site.nodes.where(state: 'public', name: file_status).first)
             Cms::RenderService.new(Page.site).render_public(node.public_uri, agent_type: Page.agent_type)
           elsif FileTest.exist?("#{Rails.public_path}/#{file_status}")
             ::File.read("#{Rails.public_path}/#{file_status}")
           elsif Page.site && (node = Page.site.nodes.where(state: 'public', name: file_500).first)
             Cms::RenderService.new(Page.site).render_public(node.public_uri, agent_type: Page.agent_type)
           elsif FileTest.exist?("#{Rails.public_path}/#{file_500}")
             ::File.read("#{Rails.public_path}/#{file_500}")
           else
             "<html>\n<head></head>\n<body>\n<p>#{message}</p>\n</body>\n</html>\n"
           end

    if Core.mode == 'ssl' && Page.site && Page.site.use_common_ssl?
      html = Cms::SslLinkReplaceService.new(Page.site, Core.request_uri.sub(/^\/_ssl\/([0-9]+)/, '')).run(html)
    end

    Page.error = status

    render status: status, inline: html, content_type: 'text/html'
    #return respond_to do |format|
    #  format.html { render status: status, inline: html }
    #  format.xml  { render status: status, xml: "<errors><error>#{message}</error></errors>" }
    #end
  end
end
