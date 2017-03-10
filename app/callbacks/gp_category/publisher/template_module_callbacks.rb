class GpCategory::Publisher::TemplateModuleCallbacks < PublisherCallbacks
  def after_save(_module)
    @module = _module
    enqueue if enqueue?
  end

  def before_destroy(_module)
    @module = _module
    enqueue if enqueue?
  end

  def enqueue(_module = nil)
    @module = _module if _module
    enqueue_templates
  end

  private

  def enqueue?
    true
  end

  def enqueue_templates
    names = [@module.name, @module.name_was].uniq.select(&:present?)
    @module.content.templates_with_name(names).each do |template|
      GpCategory::Publisher::TemplateCallbacks.new.enqueue(template)
    end
  end
end
