class Cms::Publisher::Node < Cms::Publisher
  default_scope { where(publishable_type: 'Cms::Node') }

  class << self
    def perform_publish(publishers)
      node_param = publishers.map { |pub| "target_node_id[]=#{pub.publishable_id}" }.join('&')
      ::Script.run("cms/script/nodes/publish?target_module=cms&#{node_param}", force: true)
    end
  end
end
