class Cms::Publisher::BracketeeCallbacks < PublisherCallbacks
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
                             .preload(:owner)

    owner_map = bracketees.map(&:owner).group_by { |owner| owner.class.name }
    owner_map.each do |klass_name, owners|
      next if klass_name == @item.class.name
      next unless callback = "#{klass_name.sub('::', '::Publisher::')}Callbacks".safe_constantize

      owners.each do |owner|
        callback.new.enqueue(owner)
      end
    end
  end
end
