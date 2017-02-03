class Survey::FormsScript < Cms::Script::Publication
  def publish
  end

  def publish_by_task
    if (item = params[:item]).try(:state_approved?)
      Script.current
      info_log "-- Publish: #{item.class}##{item.id}"

      if item.publish
        Sys::OperationLog.script_log(:item => item, :site => item.content.site, :action => 'publish')
      else
        raise item.errors.full_messages
      end

      info_log %Q!OK: Published to "#{item.class}##{item.id}"!
      params[:task].destroy
      Script.success
    end
  end

  def close_by_task
    if (item = params[:item]).try(:state_public?)
      Script.current
      info_log "-- Close: #{item.class}##{item.id}"

      item.close

      Sys::OperationLog.script_log(:item => item, :site => item.content.site, :action => 'close')

      info_log 'OK: Closed'
      params[:task].destroy
      Script.success
    end
  end
end
