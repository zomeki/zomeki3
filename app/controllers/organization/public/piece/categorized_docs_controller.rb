class Organization::Public::Piece::CategorizedDocsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Organization::Piece::CategorizedDoc.where(id: Page.current_piece.id).first
    return render plain: '' unless @piece

    @item = Page.current_item
  end

  def index
    return render plain: '' unless @item.is_a?(Organization::Group)  

    sys_group_ids = @item.public_descendants.map { |g| g.sys_group.id }

    @docs = @piece.content.public_docs
                  .organized_into(sys_group_ids)
                  .categorized_into(@piece.category_ids)
                  .order(@item.inherited_docs_order)

    @docs = @docs.preload_assocs(:organization_groups_and_public_node_ancestors_assocs, :public_index_assocs)
  end
end
