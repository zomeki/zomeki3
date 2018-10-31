class Reception::Task::OpensScript < TaskScript
  def expire_by_task(item)
    if item.state_public?
      ::Script.current

      item.expire

      ::Script.log "expired: #{item.course.public_uri} (#{item.title})"
      Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'expire')

      ::Script.success
      return true
    elsif item.state_closed?
      return true
    end
  end
end
