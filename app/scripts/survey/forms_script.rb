class Survey::FormsScript < PublicationScript
  def publish
    publish_page(@node, uri: @node.public_uri,
                        path: @node.public_path,
                        smart_phone_path: @node.public_smart_phone_path)
  end

  def publish_by_task(item)
    if item.state_approved? || item.state_prepared?
      ::Script.current

      if item.publish
        ::Script.log "published: #{item.public_uri}"
        Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'publish')
      else
        raise "#{item.class}##{item.id}: failed to publish"
      end

      ::Script.success
      return true
    elsif item.state_public?
      return true
    end
  end

  def close_by_task(item)
    if item.state_public?
      ::Script.current

      if item.close
        ::Script.log "closed: #{item.public_uri}"
        Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'close')
      end

      ::Script.success
      return true
    elsif item.state_closed?
      return true
    end
  end
end
