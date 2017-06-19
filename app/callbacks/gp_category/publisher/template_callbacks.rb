class GpCategory::Publisher::TemplateCallbacks < PublisherCallbacks
  def enqueue(template)
    @template = template
    return unless enqueue?
    enqueue_category_types
    enqueue_categories
  end

  private

  def enqueue_category_types
    categories = @template.public_category_types.flat_map(&:public_categories)
    Cms::Publisher.register(@template.content.site_id, categories)
  end

  def enqueue_categories
    categories = @template.public_categories.flat_map(&:public_descendants)
    Cms::Publisher.register(@template.content.site_id, categories)
  end
end
