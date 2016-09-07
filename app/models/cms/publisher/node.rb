class Cms::Publisher::Node < Cms::Publisher
  default_scope { where(publishable_type: 'Cms::Node') }

  class << self
    def perform_publish(publishers)
      pubs, extra_pubs = publishers.partition { |pub| pub.extra_flag.blank? }

      param = { target_module: 'cms', target_node_id: pubs.map(&:publishable_id) }
      ::Script.run("cms/script/nodes/publish?#{param.to_param}", force: true)

      extra_pubs.each do |pub|
        param = { target_module: 'cms', target_node_id: pub.publishable_id }.merge(pub.extra_flag)
        ::Script.run("cms/script/nodes/publish?#{param.to_param}", force: true)
      end
    end
  end
end
