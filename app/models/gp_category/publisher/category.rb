class GpCategory::Publisher::Category < Cms::Publisher
  default_scope { where(publishable_type: 'GpCategory::Category') }

  class << self
    def perform_publish(publishers)
      pub_ids = publishers.map(&:id)
      publishers = self.where(id: pub_ids).preload(publishable: { category_type: { content: :public_nodes } })
      node_map = make_node_map(publishers)
      node_map.each do |(node, category_type), pubs|
        cat_param = pubs.map { |pub| "target_category_id[]=#{pub.publishable_id}" }.join('&')
        ::Script.run("cms/script/nodes/publish?target_module=cms&target_node_id=#{node.id}&target_category_type_id=#{category_type.id}&#{cat_param}", force: true)
      end
    end

    private

    def make_node_map(publishers)
      node_map = {}
      publishers.each do |pub|
        cat = pub.publishable
        if !cat || !cat.category_type || !cat.category_type.content || cat.category_type.content.public_nodes.blank?
          pub.destroy
        else
          cat.category_type.content.public_nodes.each do |node|
            node_map[[node, cat.category_type]] ||= []
            node_map[[node, cat.category_type]] << pub
          end
        end
      end
      node_map
    end
  end
end
