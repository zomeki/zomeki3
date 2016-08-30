class GpArticle::Publisher::Doc < Cms::Publisher
  default_scope { where(publishable_type: 'GpArticle::Doc') }

  class << self
    def perform_publish(publishers)
      pub_ids = publishers.map(&:id)
      publishers = self.where(id: pub_ids).preload(publishable: { content: :public_nodes })
      node_map = make_node_map(publishers)
      node_map.each do |node, pubs|
        doc_param = pubs.map { |pub| "target_doc_id[]=#{pub.publishable_id}" }.join('&')
        ::Script.run("gp_article/script/docs/publish_doc?node_id=#{node.id}&#{doc_param}", force: true)
      end
    end

    private

    def make_node_map(publishers)
      node_map = {}
      publishers.each do |pub|
        doc = pub.publishable
        if !doc || !doc.content || doc.content.public_nodes.blank?
          pub.destroy
        else
         doc.content.public_nodes.each do |node|
            node_map[node] ||= []
            node_map[node] << pub
          end
        end
      end
      node_map
    end
  end
end
