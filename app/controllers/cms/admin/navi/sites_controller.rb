class Cms::Admin::Navi::SitesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def index
    if current_user.root?
      @sites = Cms::Site.order(:id)
    else
      # システム管理者以外は所属サイトしか操作できない
      # 管理画面URLでアクセスしたときは、そのサイト以外操作させない
      if Core.site.admin_uri?(Core.script_uri)
        @sites = [Core.site]
      else
        @sites = current_user.sites
      end
    end
    no_ajax = request.env['HTTP_X_REQUESTED_WITH'].to_s !~ /XMLHttpRequest/i
    render :layout => no_ajax
  end

  def show
    render :text => ""
  end
end
