class Cms::Controller::Public::Base < Sys::Controller::Public::Base
  include Cms::Controller::Layout

  before_action :initialize_params
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

  def http_error(status, message = nil)
    self.response_body = nil
    Page.error = status

    if Page.mobile
      file_status = "#{status}_mobile.html"
      file_500 = "500_mobile.html"
    else
      file_status = "#{status}.html"
      file_500 = "500.html"
    end

    html = if Page.site && FileTest.exist?("#{Page.site.public_path}/#{file_status}")
             ::File.read("#{Page.site.public_path}/#{file_status}")
           elsif FileTest.exist?("#{Rails.public_path}/#{file_status}")
             ::File.read("#{Rails.public_path}/#{file_status}")
           elsif FileTest.exist?("#{Rails.public_path}/#{file_500}")
             ::File.read("#{Rails.public_path}/#{file_500}")
           else
             "<html>\n<head></head>\n<body>\n<p>#{message}</p>\n</body>\n</html>\n"
           end

    if Core.mode == 'ssl'
      html = Cms::Public::SslLinkReplaceService.new(Page.site, Page.current_node).run(html)
    end

    render status: status, inline: html, content_type: 'text/html'
    #return respond_to do |format|
    #  format.html { render :status => status, :inline => html }
    #  format.xml  { render :status => status, :xml => "<errors><error>#{message}</error></errors>" }
    #end
  end
end
