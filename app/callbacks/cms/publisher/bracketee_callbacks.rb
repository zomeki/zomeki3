class Cms::Publisher::BracketeeCallbacks < PublisherCallbacks
  OWNER_KLASS_NAMES = %w(Cms::Layout Cms::Piece Cms::Node GpArticle::Doc)
  
  def enqueue(item)
    @item = item
    return unless enqueue?
    enqueue_bracketees
  end

  private

  def enqueue?
    return unless super
    @item.name.present?
  end

  def enqueue_bracketees
    bracketees = Cms::Bracket.where(site_id: @item.site_id)
                             .ci_match(name: @item.changed_bracket_names)
                             .preload(:owner).all
    return if bracketees.blank?

    owner_map = bracketees.map(&:owner).group_by { |owner| owner.class.name }

    OWNER_KLASS_NAMES.each do |klass_name|
      if klass_name != @item.class.name && owner_map[klass_name].present?
        owner_map[klass_name].each do |owner|
          "#{klass_name.sub('::', '::Publisher::')}Callbacks".constantize.new.enqueue(owner)
        end
      end
    end
  end
end
