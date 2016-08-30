class Cms::NodePublisherJob < ApplicationJob
  queue_as :cms_node_publisher

  def perform
    publishers = Cms::NodePublisher.order(:id).all
    return if publishers.blank?

    publishers.each_slice(100) do |pubs|
      node_param = pubs.map { |pub| "target_node_id[]=#{pub.node_id}" }.join('&')
      ::Script.run("cms/script/nodes/publish?target_module=cms&#{node_param}", force: true)
      pubs.each(&:destroy)
    end
  end
end
