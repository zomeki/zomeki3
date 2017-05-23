class Cms::NodesScript < Cms::Script::Publication
  include Sys::Lib::File::Transfer

  def publish
    @ids = {}

    nodes = Cms::Node.public_state.order(:name, :id)
    nodes.where!(site_id: ::Script.site.id) if ::Script.site

    if params.key?(:target_node_id)
      nodes.where(id: params[:target_node_id]).each do |node|
        publish_node(node)
        file_transfer_callbacks.after_publish_files(node)
      end
    else
      nodes.where(parent_id: 0).each do |node|
        publish_node(node)
        file_transfer_callbacks.after_publish_files(node)
      end
    end

    # file transfer
    transfer_files(logging: true) if Zomeki.config.application['sys.transfer_to_publish']
  end

  def file_transfer_callbacks
    FileTransferCallbacks.new([:public_path, :public_smart_phone_path], recursive: true)
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
        publish_page(node, uri: uri, site: node.site, path: node.public_path,
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
        script_klass = node.script_klass
        return unless script_klass.publishable?

        publish_page(node, uri: node.public_uri, site: node.site, path: node.public_path,
                                                      smart_phone_path: node.public_smart_phone_path)
        script_klass.new(params.merge(node: node)).publish

      rescue ::Script::InterruptException => e
        raise e
      rescue LoadError => e
        ::Script.error "#{node.class}##{node.id} #{e}"
        return
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

  def publish_by_task(item)
    return if item.model != 'Cms::Page'

    if item.state == 'recognized'
      ::Script.current
      info_log "-- Publish: #{item.class}##{item.id}"

      item = Cms::Node::Page.find(item.id)
      uri  = "#{item.public_uri}?node_id=#{item.id}"
      path = "#{item.public_path}"

      unless item.publish(render_public_as_string(uri, site: item.site))
        raise item.errors.full_messages
      else
        Sys::OperationLog.script_log(item: item, site: item.site, action: 'publish')
      end

      ruby_uri  = (uri =~ /\?/) ? uri.gsub(/(.*\.html)\?/, '\\1.r?') : "#{uri}.r"
      ruby_path = "#{path}.r"
      if item.published? || !::File.exist?(ruby_uri)
        item.publish_page(render_public_as_string(ruby_uri, site: item.site),
                          path: ruby_path, dependent: :ruby)
      end

      info_log %Q!OK: Published to "#{path}"!
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
