class GpCategory::PublisherJob < ApplicationJob
  queue_as :gp_category_publisher

  def perform
    publishers = GpCategory::Publisher.order(:id).preload(category: { category_type: { content: :public_nodes }})
    return if publishers.blank?

    node_map = make_node_map(publishers)
    node_map.each do |(node, category_type), pubs|
      pubs.each_slice(100) do |sliced_pubs|
        cat_param = pubs.map { |pub| "target_category_id[]=#{pub.category_id}" }.join('&')
        ::Script.run("cms/script/nodes/publish?target_module=cms&target_node_id=#{node.id}&target_category_type_id=#{category_type.id}&#{cat_param}", force: true)
        sliced_pubs.each(&:destroy)
      end
    end
  end

  private

  def make_node_map(publishers)
    node_map = {}
    publishers.each do |pub|
      cat = pub.category
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
