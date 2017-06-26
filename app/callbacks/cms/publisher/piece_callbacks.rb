class Cms::Publisher::PieceCallbacks < PublisherCallbacks
  def enqueue(pieces)
    @pieces = pieces
    return unless enqueue?

    @site = @pieces.first.site
    enqueue_layouts
  end

  private

  def enqueue?
    return unless super
    @pieces = Array(@pieces).select { |piece| piece.name.present? }
    @pieces.present?
  end

  def enqueue_layouts
    layouts = Cms::Bracket.where(site_id: @site.id, owner_type: 'Cms::Layout')
                          .ci_match(name: @pieces.flat_map(&:changed_bracket_names).uniq)
                          .preload(:owner)
                          .map(&:owner).uniq
    return if layouts.blank?

    Cms::Publisher::LayoutCallbacks.new.enqueue(layouts)
  end
end
