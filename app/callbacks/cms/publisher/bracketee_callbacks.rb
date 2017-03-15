class Cms::Publisher::BracketeeCallbacks < PublisherCallbacks
  OWNER_KLASS_NAMES = %w(Cms::Layout Cms::Piece Cms::Node GpArticle::Doc)
  
  def after_save(item)
    @item = item
    enqueue if enqueue?
  end

  def before_destroy(item)
    @item = item
    enqueue if enqueue?
  end

  def enqueue(item = nil)
    @item = item if item
    enqueue_bracketees
  end

  private

  def enqueue?
    @item.name.present?
  end

  def enqueue_bracketees
    bracketees = Cms::Bracket.where(site_id: @item.site_id, name: changed_bracket_names).preload(:owner).all
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

  def changed_bracket_names
    type = Cms::Lib::Bracket.bracket_type(@item)
    names = [@item.name, @item.name_was].select(&:present?).uniq
    names.map { |name| "#{type}/#{name}" }
  end
end
