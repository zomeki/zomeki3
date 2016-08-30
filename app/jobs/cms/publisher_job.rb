class Cms::PublisherJob < ApplicationJob
  queue_as :cms_publisher

  def perform
    loop_count = 0
    while Cms::Publisher.exists? && (loop_count += 1) <= 100
      publishers = Cms::Publisher.order(:priority, :id).limit(30).all
      break if publishers.blank?
  
      publishers.update_all(state: 'running')

      publisher_map = publishers.group_by(&:publishable_type)
      publisher_map.each do |pub_type, pubs|
        pub_model = pub_type.gsub(/(\w+::)(\w+)/, '\\1Publisher::\\2').constantize
        pub_model.perform_publish(pubs)
      end

      publishers.destroy_all
    end
  end
end
