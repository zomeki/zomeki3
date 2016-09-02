class GpArticle::Publisher::Doc < Cms::Publisher
  default_scope { where(publishable_type: 'GpArticle::Doc') }

  class << self
    def perform_publish(publishers)
      pub_ids = publishers.map(&:id)
      publishers = self.where(id: pub_ids).preload(publishable: { content: :public_nodes })

      node_map = make_node_map(publishers)
      node_map.each do |node, pubs|
        param = {
          node_id: node.id,
          target_doc_id: pubs.map(&:publishable_id)
        }
        ::Script.run("gp_article/script/docs/publish_doc?#{param.to_param}", force: true)
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
