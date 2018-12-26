class GpCategory::Publisher::TemplateModuleCallbacks < PublisherCallbacks
  def enqueue(_module)
    @module = _module
    return unless enqueue?
    enqueue_templates
  end

  private

  def enqueue_templates
    names = [@module.name, @module.name_before_last_save].uniq.select(&:present?)
    @module.content.templates_with_name(names).each do |template|
      GpCategory::Publisher::TemplateCallbacks.new.enqueue(template)
    end
  end
end
