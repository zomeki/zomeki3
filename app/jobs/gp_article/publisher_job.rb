class GpArticle::PublisherJob < ApplicationJob
  queue_as :gp_article_publisher

  def perform
    publishers = GpArticle::Publisher.order(:id).all.preload(doc: { content: :public_nodes })
    return if publishers.blank?

    node_map = make_node_map(publishers)
    node_map.each do |node, pubs|
      pubs.each_slice(100) do |sliced_pubs|
        doc_param = sliced_pubs.map { |pub| "target_doc_id[]=#{pub.doc_id}" }.join('&')
        ::Script.run("gp_article/script/docs/publish_doc?node_id=#{node.id}&#{doc_param}", force: true)
        sliced_pubs.each(&:destroy)
      end
    end
  end

  private

  def make_node_map(publishers)
    node_map = {}
    publishers.each do |pub|
      doc = pub.doc
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
