class Tag::Publisher::Tag < Cms::Publisher
  default_scope { where(publishable_type: 'Tag::Tag') }

  class << self
    def perform_publish(publishers)
      pub_ids = publishers.map(&:id)
      publishers = self.where(id: pub_ids).preload(publishable: { content: :public_nodes })
      node_map = make_node_map(publishers)
      node_map.each do |node, pubs|
        tag_param = pubs.map { |pub| "target_tag_id[]=#{pub.publishable_id}" }.join('&')
        ::Script.run("cms/script/nodes/publish?target_module=cms&target_node_id=#{node.id}&#{tag_param}", force: true)
      end
    end

    private

    def make_node_map(publishers)
      node_map = {}
      publishers.each do |pub|
        tag = pub.publishable
        if !tag || !tag.content || tag.content.public_nodes.blank?
          pub.destroy
        else
          tag.content.public_nodes.each do |node|
            node_map[node] ||= []
            node_map[node] << pub
          end
        end
      end
      node_map
    end
  end
end
