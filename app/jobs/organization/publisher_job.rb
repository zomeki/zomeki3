class Organization::PublisherJob < ApplicationJob
  queue_as :organization_publisher

  def perform
    publishers = Organization::Publisher.order(:id).preload(organization_group: { content: :public_nodes })
    return if publishers.blank?

    node_map = make_node_map(publishers)
    node_map.each do |node, pubs|
      pubs.each_slice(100) do |sliced_pubs|
        og_param = sliced_pubs.map { |pub| "target_organization_group_id[]=#{pub.organization_group_id}" }.join('&')
        ::Script.run("cms/script/nodes/publish?target_module=cms&target_node_id=#{node.id}&#{og_param}", force: true)
        sliced_pubs.each(&:destroy)
      end
    end
  end

  private

  def make_node_map(publishers)
    node_map = {}
    publishers.each do |pub|
      og = pub.organization_group
      if !og || !og.content || og.content.public_nodes.blank?
        pub.destroy
      else
        og.content.public_nodes.each do |node|
          node_map[node] ||= []
          node_map[node] << pub
        end
      end
    end
    node_map
  end
end
