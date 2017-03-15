class GpCategory::Publisher::TemplateCallbacks < PublisherCallbacks
  def after_save(template)
    @template = template
    enqueue if enqueue?
  end

  def before_destroy(template)
    @template = template
    enqueue if enqueue?
  end

  def enqueue(template = nil)
    @template = template if template
    enqueue_category_types
    enqueue_categories
  end

  private

  def enqueue?
    true
  end

  def enqueue_category_types
    categories = @template.public_category_types.flat_map(&:public_categories)
    Cms::Publisher.register(@template.content.site_id, categories)
  end

  def enqueue_categories
    categories = @template.public_categories.flat_map(&:public_descendants)
    Cms::Publisher.register(@template.content.site_id, categories)
  end
end
