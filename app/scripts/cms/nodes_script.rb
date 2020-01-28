class Cms::NodesScript < PublicationScript
  def publish
    @ids = {}

    nodes = Cms::Node.public_state.order(:name, :id)
    nodes.where!(site_id: ::Script.site.id) if ::Script.site

    if params.key?(:target_node_id)
      nodes.where(id: params[:target_node_id]).each do |node|
        publish_node(node)
      end
    else
      nodes.where(parent_id: 0).each do |node|
        publish_node(node)
      end
      publish_pieces
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
        file_transfer_callbacks(node)
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
        script_klass = "#{node.model.pluralize.sub('::', '::Node::')}Script".safe_constantize
        if script_klass && script_klass.method_defined?(:publish)
          script_klass.new(params.merge(node: node)).publish
          file_transfer_callbacks(node)
        end
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
  
  def publish_pieces
    models = Cms::Piece.publishable_models
    
    pieces = Cms::Piece.public_state.where(model: models).order(:name, :id)
    pieces.where!(site_id: ::Script.site.id) if ::Script.site
    
    pieces.each do |piece|
      begin
        script_klass = "#{piece.model.pluralize.sub('::', '::Piece::')}Script".safe_constantize
        if script_klass && script_klass.method_defined?(:publish)
          script_klass.new(params.merge(piece: piece)).publish
          file_transfer_callbacks(piece)
        end
      rescue ::Script::InterruptException => e
        raise e
      rescue Exception => e
        ::Script.error "#{piece.class}##{piece.id} #{e}"
        return
      end
    end

    
  end

  def file_transfer_callbacks(node)
    Cms::FileTransferCallbacks.new([:public_path, :public_smart_phone_path], recursive: !node.model.in?(%w(Cms::Page Cms::Sitemap)))
                              .after_publish_files(node)
  end
end
