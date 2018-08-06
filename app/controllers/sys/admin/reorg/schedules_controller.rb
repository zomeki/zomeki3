class Sys::Admin::Reorg::SchedulesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_action :set_item, only: [:edit, :update, :destroy]

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def edit
  end

  def update
    @item.attributes = schedule_params
    @item.state = 'reserved'

    _update @item, location: sys_reorg_groups_path(0), notice: '組織変更を予約しました。' do
      Sys::Reorg::ExecJob.set(wait_until: @item.reserved_at).perform_later(@item)
    end
  end

  def destroy
    _destroy @item, location: sys_reorg_groups_path(0)
  end

  private

  def schedule_params
    params.require(:item).permit(:reserved_at)
  end

  def set_item
    @item = Sys::Reorg::Schedule.where(site: Core.site).first_or_initialize
  end
end
