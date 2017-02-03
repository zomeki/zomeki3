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

    per_page = (@more ? 30 : @content.num_docs)

    settings = GpArticle::Content::Setting.arel_table
    article_contents = GpArticle::Content::Doc.joins(:settings)
                                              .where(settings[:name].eq('organization_content_group_id')
                                                                        .and(settings[:value].eq(@content.id)))
                                              .where(site_id: @content.site.id)
    if params[:format].in?(['rss', 'atom'])
      docs = if article_contents.empty?
          GpArticle::Doc.none
        else
          sys_group_ids = @group.public_descendants.map{|g| g.sys_group.id }
          docs = find_public_docs_with_group_id(sys_group_ids)
          docs = docs.where(content_id: article_contents.pluck(:id))
          docs = docs.order(@group.docs_order)
          docs = docs.display_published_after(@content.feed_docs_period.to_i.days.ago) if @content.feed_docs_period.present?
          docs = docs.paginate(page: params[:page], per_page: @content.feed_docs_number)
          docs = docs.preload_assocs(:organization_groups_and_public_node_ancestors_assocs, :public_index_assocs)
          docs
        end
      return render_feed(docs)
    end

    @docs = if article_contents.empty?
              GpArticle::Doc.none
            else
              sys_group_ids = @group.public_descendants.map{|g| g.sys_group.id }
              find_public_docs_with_group_id(sys_group_ids)
                .where(content_id: article_contents.pluck(:id))
                .order(@group.docs_order)
                .preload_assocs(:organization_groups_and_public_node_ancestors_assocs, :public_index_assocs)
            end
    @docs = @docs.paginate(page: params[:page], per_page: per_page)
    return http_error(404) if @docs.current_page > @docs.total_pages

    render 'more' if @more
  end

  private

  def find_public_docs_with_group_id(group_id)
    GpArticle::Doc.organized_into(group_id).mobile(::Page.mobile?).public_state
  end
end
