class Cms::Admin::Navi::SitesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def index
    @sites =
      if current_user.root?
        Cms::Site.order(:id)
      else
        current_user.sites
      end
    no_ajax = request.env['HTTP_X_REQUESTED_WITH'].to_s !~ /XMLHttpRequest/i
    render layout: no_ajax
  end

  def show
    render plain: ""
  end
end
