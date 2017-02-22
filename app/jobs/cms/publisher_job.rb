class Cms::PublisherJob < ApplicationJob
  queue_as :cms_publisher
  queue_with_priority 20

  MAX_LOOP = 1000

  def perform
    loop_count = 0
    while Cms::Publisher.exists?
      if (loop_count += 1) > MAX_LOOP
        Cms::PublisherJob.perform_later
        break
      end

      publishers = []
      Cms::Publisher.transaction do
        publishers = Cms::Publisher.queued_items.order(:priority, :id).limit(10).lock
        Cms::Publisher.where(id: publishers.map(&:id)).update_all(state: 'performing')
      end
      break if publishers.blank?

      grouped_pubs = publishers.group_by { |p| [p.priority, p.site_id, p.publishable_type] }.sort
      grouped_pubs.each do |(priority, site_id, pub_type), pubs|
        pub_model = pub_type.gsub(/(\w+::)(\w+)/, '\\1Publisher::\\2').constantize
        pub_model.perform_publish(pubs)
        pubs.each(&:destroy)
      end
    end
  end
end
