class Cms::RebuildLinkJob < ApplicationJob
  def perform(site = nil)
    rebuild_links(site)
  end

  private

  def rebuild_links(site)
    models = Cms::Link.group(:linkable_type)
                      .pluck(:linkable_type)
                      .map { |type| type.sub('Cms::Node', 'Cms::Node::Page').constantize }
    models.each do |model|
      items = model
      items = items.in_site(site) if site
      items.find_each(&:save_links)
    end
  end

end
