class Reception::Script::OpensController < Cms::Controller::Script::Publication
  def expire_by_task
    if (item = params[:item]) && item.state_public?
      Script.current
      info_log "-- Expire: #{item.class}##{item.id}"

      item.expire

      Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'expire')

      info_log 'OK: Expired'
      params[:task].destroy
      Script.success
    end
    render plain: 'OK'
  rescue => e
    error_log "#{__FILE__}:#{__LINE__} #{e.message}"
    render plain: 'NG'
  end
end
