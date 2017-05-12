class Survey::FormsScript < Cms::Script::Publication
  def publish
  end

  def publish_by_task(item)
    if item.state_approved?
      ::Script.current
      info_log "-- Publish: #{item.class}##{item.id}"

      if item.publish
        Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'publish')
      else
        raise item.errors.full_messages
      end

      info_log %Q!OK: Published to "#{item.class}##{item.id}"!
      ::Script.success
      return true
    elsif item.state_public?
      return true
    end
  end

  def close_by_task(item)
    if item.state_public?
      ::Script.current
      info_log "-- Close: #{item.class}##{item.id}"

      item.close

      Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'close')

      info_log 'OK: Closed'
      ::Script.success
      return true
    elsif item.state_closed?
      return true
    end
  end
end
