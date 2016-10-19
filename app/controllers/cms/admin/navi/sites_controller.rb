class Cms::Admin::Navi::SitesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def index
    if Core.site.site_domain?(Core.script_uri)
      @sites = [Core.site]
    else
      if current_user.root?
        @sites = Cms::Site.order(:id)
      else
        @sites = current_user.sites
      end
    end
    no_ajax = request.env['HTTP_X_REQUESTED_WITH'].to_s !~ /XMLHttpRequest/i
    render :layout => no_ajax
  end

  def show
    render plain: ""
  end
end
