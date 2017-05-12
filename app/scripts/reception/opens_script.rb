class Reception::OpensScript < Cms::Script::Publication
  def expire_by_task(item)
    if item.state_public?
      ::Script.current
      info_log "-- Expire: #{item.class}##{item.id}"

      item.expire

      Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'expire')

      info_log 'OK: Expired'
      ::Script.success
      return true
    elsif item.state_closed?
      return true
    end
  end
end
