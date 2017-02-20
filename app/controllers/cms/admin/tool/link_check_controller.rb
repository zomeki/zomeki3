class Cms::Admin::Tool::LinkCheckController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:creator)
    return redirect_to(action: :index) if params[:reset]

    params[:limit] ||= '30'
  end

  def index
    if request.post?
      Util::LinkChecker.check(Core.site)
      return redirect_to action: :index
    end

    site_logs = Cms::LinkCheckLog.where(site_id: Core.site.id)

    @logs = site_logs.search_with_params(params).order(:id)
                     .paginate(page: params[:page], per_page: params[:limit])

    if (@running = site_logs.where(checked: false).exists?)
      current = site_logs.where(checked: true).count
      total = site_logs.count
      flash.now[:notice] = "リンクチェックを実行中です。(#{current}/#{total}件)"
    end
  end
end
