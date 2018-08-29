class Sys::Admin::Reorg::RunnersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
    @groups = Sys::Reorg::Group.in_site(Core.site).where.not(change_state: nil).order(:code, :id)
                               .preload(:source_groups, :destination_groups)
    @users = Sys::Reorg::User.in_site(Core.site).where.not(change_state: nil).order(:account, :id)
                             .preload(:source_users, :destination_users)

    delete_groups = Sys::Reorg::Group.in_site(Core.site).where(change_state: 'delete')
    @group_unknown_users = Sys::Reorg::User.in_group(delete_groups)
  end

  def init
    Sys::Reorg::ClearJob.perform_now(Core.site)
    Sys::Reorg::CopyJob.perform_now(Core.site)
    redirect_to sys_reorg_groups_path(0), notice: '現在のグループ情報をコピーしました。'
  end

  def exec
    Sys::Reorg::Schedule.in_site(Core.site).destroy_all
    ::Script.run('sys/reorgs/exec', site_id: Core.site.id)
    redirect_to sys_reorg_groups_path(0), notice: '組織変更を実行しました。'
  end

  def clear
    Sys::Reorg::ClearJob.perform_now(Core.site)
    redirect_to sys_reorg_groups_path(0), notice: '組織変更を削除しました。'
  end
end
