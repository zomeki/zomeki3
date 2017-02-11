class Tag::Public::Node::TagsController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = Tag::Content::Tag.find_by(id: Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    @items = @content.tags
                     .paginate(page: params[:page], per_page: 50)
                     .preload_assocs(:public_node_ancestors_assocs)
    return http_error(404) if @items.current_page > @items.total_pages
  end

  def show
    http_error(404) if params[:page]

    @item = @content.tags.find_by(word: params[:word])
    return http_error(404) unless @item

    Page.current_item = @item
    Page.title = @node.title

    @docs = @item.public_docs.preload_assocs(:public_node_ancestors_assocs, :public_index_assocs)
  end
end
