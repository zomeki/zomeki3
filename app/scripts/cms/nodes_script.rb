class Cms::NodesScript < PublicationScript
  def publish
    @ids = {}

    nodes = Cms::Node.public_state.order(:name, :id)
    nodes.where!(site_id: ::Script.site.id) if ::Script.site

    if params.key?(:target_node_id)
      nodes.where(id: params[:target_node_id]).each do |node|
        publish_node(node)
        file_transfer_callbacks(node)
      end
    else
      nodes.where(parent_id: 0).each do |node|
        publish_node(node)
        file_transfer_callbacks(node)
      end
    end
  end

  def publish_node(node)
    started_at = Time.now
    info_log "Publish node: #{node.model} #{node.name} #{node.title}"

    return if @ids.key?(node.id)
    @ids[node.id] = true

    return unless node.site

    unless node.public?
      node.close_page
      return
    end

    ## page
    if node.model == 'Cms::Page'
      begin
        uri = "#{node.public_uri}?node_id=#{node.id}"
        publish_page(node, uri: uri,
                           site: node.site,
                           path: node.public_path,
                           smart_phone_path: node.public_smart_phone_path)
      rescue ::Script::InterruptException => e
        raise e
      rescue => e
        ::Script.error "#{node.class}##{node.id} #{e}"
      end
      return
    end

    ## modules' page
    unless node.model == 'Cms::Directory'
      begin
        script_klass = "#{node.model.pluralize}Script".safe_constantize
        script_klass.new(params.merge(node: node)).publish if script_klass && script_klass.method_defined?(:publish)
      rescue ::Script::InterruptException => e
        raise e
      rescue Exception => e
        ::Script.error "#{node.class}##{node.id} #{e}"
        return
      end
    end

    child_nodes = Cms::Node.where(parent_id: node.id)
                           .where.not(name: [nil, ''])
                           .order(:directory, :name, :id)
    child_nodes.each do |child_node|
      publish_node(child_node)
    end

    info_log "Published node: #{node.model} #{node.name} #{node.title} in #{(Time.now - started_at).round(2)} [secs.]"
  end

  def file_transfer_callbacks(node)
    FileTransferCallbacks.new([:public_path, :public_smart_phone_path], recursive: !node.model.in?(%w(Cms::Page Cms::Sitemap)))
                         .after_publish_files(node)
  end

  def publish_by_task(item)
    return if item.model != 'Cms::Page'

    if item.state == 'recognized'
      ::Script.current
      info_log "-- Publish: #{item.class}##{item.id}"

      item = Cms::Node::Page.find(item.id)

      if item.publish
        Sys::OperationLog.script_log(item: item, site: item.site, action: 'publish')
      else
        raise item.errors.full_messages
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
