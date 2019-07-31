class AdBanner::Task::BannersScript < TaskScript
  def publish_by_task(item)
    if item.state_prepared?
      ::Script.current

      if item.publish
        ::Script.log "published: AdBanner[#{item.title}]"
        Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'publish')
      else
        raise "#{item.class}##{item.id}: failed to publish"
      end

      ::Script.success
    end
    return true
  end

  def close_by_task(item)
    if item.state_public?
      ::Script.current

      if item.close
        ::Script.log "closed: AdBanner[#{item.title}]"
        Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'close')
      end

      ::Script.success
      return true
    elsif item.state_closed?
      return true
    end
  end
end
