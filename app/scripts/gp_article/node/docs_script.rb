class GpArticle::Node::DocsScript < PublicationScript
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
      paginator = content.docs_for_list.public_state
                         .date_paginate(content.docs_order_column, content.docs_order_direction, scope: content.doc_list_pagination)
                         .paginator
      if params[:target_date].present?
        publish_target_dates(@node, common_params.merge(
                                    page_style: content.doc_list_pagination,
                                    first_date: paginator.pages.first || Date.today,
                                    target_dates: load_neighbor_dates(content.doc_list_pagination, paginator.pages, params[:target_date])))
      else
        publish_more_dates(@node, common_params.merge(
                                  page_style: content.doc_list_pagination,
                                  page_dates: paginator.pages))
      end
    end
  end

  def load_neighbor_dates(style, pages, target_date)
    neighbors = []
    Array(target_date).each do |date|
      date = case style.to_sym
             when :monthly
               Date.parse(date).beginning_of_month
             when :weekly
               Date.parse(date).beginning_of_week
             end
      if (i = pages.index(date))
        neighbors += [pages[i - 1], pages[i], pages[i + 1]]
      end
    end
    neighbors.compact.uniq
  end
end
