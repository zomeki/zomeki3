class Cms::Admin::Tool::LinkCheckController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:creator)
    return redirect_to(action: :index) if params[:reset]

    params[:limit] ||= '30'
  end

  def index
    logs = Cms::LinkCheckLog.where(site_id: Core.site.id)

    @logs = logs.search_with_params(params).order(:id)
                     .paginate(page: params[:page], per_page: params[:limit])
                     .preload(link_checkable: { creator: :group })

    if (@running = logs.where(checked: false).exists?)
      current = logs.where(checked: true).count
      total = logs.count
      flash.now[:notice] = "リンクチェックを実行中です。(#{current}/#{total}件)"
    end
  end
end
