class Cms::Task::NodesScript < TaskScript
  def publish_by_task(item)
    return if item.model != 'Cms::Page'

    if item.state == 'recognized'
      ::Script.current
      info_log "-- Publish: #{item.class}##{item.id}"

      item = Cms::Node::Page.find(item.id)

      if item.publish
        Sys::OperationLog.script_log(item: item, site: item.site, action: 'publish')
      else
        raise "#{item.class}##{item.id}: failed to publish"
      end

      info_log 'OK: Published'
      ::Script.success
      return true
    elsif item.state == 'public'
      return true
    end
  end

  def close_by_task(item)
    return if item.model != 'Cms::Page'

    if item.state == 'public'
      ::Script.current
      info_log "-- Close: #{item.class}##{item.id}"

      item = Cms::Node::Page.find(item.id)

      if item.close
        Sys::OperationLog.script_log(item: item, site: item.site, action: 'close')
      end

      info_log 'OK: Closed'
      ::Script.success
      return true
    elsif item.state == 'closed'
      return true
    end
  end
end
