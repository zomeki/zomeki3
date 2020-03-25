class GpCategory::Publisher::CategoryCallbacks < PublisherCallbacks
  def enqueue(category)
    @category = category
    return unless enqueue?
    enqueue_pieces
    enqueue_categories
    enqueue_docs
    enqueue_gnav
  end

  private

  def enqueue?
    return unless super
    [@category.state, @category.state_before_last_save].include?('public')
  end

  def enqueue_pieces
    pieces = @category.content.public_pieces.sort { |p| p.model == 'GpCategory::RecentTab' ? 1 : 9 }
    Cms::Publisher::PieceCallbacks.new.enqueue(pieces)
  end

  def enqueue_categories
    Cms::Publisher.register(@category.content.site_id, @category.public_ancestors)
  end

  def enqueue_docs
    docs = GpArticle::Doc.public_state.categorized_into(@category.public_descendants).select(:id)
    Cms::Publisher.register(@category.content.site_id, docs)
  end
  
  def enqueue_gnav
    Gnav::Content::MenuItem.in_site(@category.content.site_id).each do |gnav_content|
      next unless category_content = gnav_content.gp_category_content_category_type
      next unless category_content.id == @category.content.id
      
      Cms::Publisher.register(@category.content.site_id, gnav_content.public_nodes)
      Cms::Publisher::PieceCallbacks.new.enqueue(gnav_content.public_pieces)
    end
    
  end
end
