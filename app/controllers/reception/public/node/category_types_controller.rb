class Reception::Public::Node::CategoryTypesController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = Reception::Content::Course.find(@node.content_id)
  end

  def index
    @category_types = @content.pubilc_category_types
  end

  def show
    @category_type = @content.pubilc_category_types.find_by!(name: params[:category_type_name])
    Page.current_item = @category_type.becomes(Reception::CategoryType) # becomes for bread crumbs
    Page.title = @category_type.title
  end
end
