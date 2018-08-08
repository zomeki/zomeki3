class Sys::Reorg::ExecJob < ApplicationJob
  queue_as :default
  queue_with_priority 10

  def perform(site)
    schedule = Sys::Reorg::Schedule.where(site: site).first
    return unless schedule

    if schedule.state == 'reserved' && schedule.reserved_at && schedule.reserved_at <= Time.now
      schedule.update_columns(state: 'performing')
      ::Script.run('sys/reorgs/exec', site_id: site.id)
      schedule.update_columns(state: 'performed')
    end
  end
end
