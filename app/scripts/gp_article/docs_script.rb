class GpArticle::DocsScript < PublicationScript
  def publish
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_page(@node, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
    publish_page(@node, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)

    content = @node.content
    common_params = { uri: uri, path: path, smart_phone_path: smart_phone_path }
    if content.doc_list_pagination == 'simple'
      publish_more(@node, common_params.merge(limit: content.doc_publish_more_pages))
    else
      if params[:target_date].present?
        publish_target_dates(@node, common_params.merge(
                                    page_style: content.doc_list_pagination,
                                    first_date: date_pagination_query(content).first_page_date,
                                    target_dates: load_neighbor_dates(content, params[:target_date])))
      else
        publish_more_dates(@node, common_params.merge(
                                  page_style: content.doc_list_pagination,
                                  page_dates: date_pagination_query(content).page_dates))
      end
    end
  end

  def date_pagination_query(content, current_date = nil)
    DatePaginationQuery.new(content.public_docs_for_list,
                            page_style: content.doc_list_pagination,
                            column: content.docs_order_column,
                            direction: content.docs_order_direction,
                            current_date: current_date)
  end

  def load_neighbor_dates(content, target_date)
    dates = []
    Array(target_date).each do |date|
      current_date = Time.parse(date)
      query = date_pagination_query(content, current_date)
      dates += [query.next_page_date, current_date, query.prev_page_date]
    end
    dates.compact.uniq
  end

  def publish_doc
    docs = @node.content.public_docs.where(id: params[:target_doc_id])
    docs.find_each do |doc|
      ::Script.progress(doc) do
        doc.rebuild
      end
    end

    FileTransferCallbacks.new([:public_path, :public_smart_phone_path], recursive: true).after_publish_files(@node)
  end

  def publish_by_task(item)
    if (item.state_approved? || item.state_prepared?)
      ::Script.current
      info_log "-- Publish: #{item.class}##{item.id}"

      if item.publish
        Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'publish')
      else
        raise item.errors.full_messages
      end

      info_log 'OK: Published'
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

      if item.close
        Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'close')
      end

      info_log 'OK: Finished'
      ::Script.success
      return true
    elsif item.state_closed?
      return true
    end
  end
end
