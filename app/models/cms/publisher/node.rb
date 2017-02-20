class Cms::Publisher::Node < Cms::Publisher
  default_scope { where(publishable_type: 'Cms::Node') }

  class << self
    def perform_publish(publishers)
      pubs, extra_pubs = publishers.partition { |pub| pub.extra_flag.blank? }

      if pubs.size > 0
        ::Script.run("cms/nodes/publish",
          site_id: pubs.first.site_id,
          target_node_id: pubs.map(&:publishable_id)
        )
      end
      extra_pubs.each do |pub|
        ::Script.run("cms/nodes/publish", pub.extra_flag.reverse_merge(
          site_id: pub.site_id,
          target_node_id: pub.publishable_id
        ))
      end
    end
  end
end
