class Organization::Public::Node::GroupsController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed
  def pre_dispatch
    @content = Organization::Content::Group.find_by(id: Page.current_node.content.id)
    return http_error(404) unless @content
    @more = (params[:filename_base] =~ /^more($|_)/i)
  end

  def index
    @groups = @content.top_layer_groups.public_state
                      .preload_assocs(:public_node_ancestors_assocs)
  end

  def show
    @group = @content.find_group_by_path_from_root(params[:group_names])
    return http_error(404) unless @group.try(:public?)

    Page.current_item = @group
    Page.title = @group.sys_group.name

    sys_group_ids = @group.public_descendants.map { |g| g.sys_group.id }

    docs = @content.public_docs.organized_into(sys_group_ids)
                   .order(@group.inherited_docs_order)
                   .preload_assocs(:organization_groups_and_public_node_ancestors_assocs, :public_index_assocs)

    if params[:format].in?(['rss', 'atom'])
      docs = docs.display_published_after(@content.feed_docs_period.to_i.days.ago) if @content.feed_docs_period.present?
      docs = docs.paginate(page: params[:page], per_page: @content.feed_docs_number)
      return render_feed(docs)
    end

    @docs = docs.paginate(page: params[:page], per_page: (@more ? 30 : @content.num_docs))
    return http_error(404) if @docs.current_page > @docs.total_pages

    render 'more' if @more
  end
end
