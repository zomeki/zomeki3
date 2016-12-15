class Cms::Publisher < ApplicationRecord
  include Sys::Model::Base

  STATE_OPTIONS = [['待機中','queued'],['実行中','performing']]

  belongs_to :publishable, polymorphic: true

  validate :validate_queue, on: :create

  private

  def validate_queue
    if self.class.where(state: 'queued', publishable_id: publishable_id, publishable_type: publishable_type)
           .where("extra_flag = ?", extra_flag.to_json)
           .exists?
      errors.add(:publishable_id, :taken)
    end
  end

  class << self
    def register(site_id, items, extra_flag = {})
      items = Array(items)
      return if items.blank?

      pubs = items.map do |item|
        priority = if item.is_a?(Cms::Node) &&
          node_item = Cms::Node.find_by(id: item.id)
          if node_item.present? && node_item.top_page?
            10
          else
            30
          end
        elsif item.is_a?(GpCategory::Category)
          20
        else
          30
        end
        self.new(site_id: site_id, publishable: item, state: 'queued', extra_flag: extra_flag, priority: priority)
      end
      self.import(pubs)

      Cms::PublisherJob.set(priority: 20).perform_later unless Cms::PublisherJob.queued?
    end
  end
end
