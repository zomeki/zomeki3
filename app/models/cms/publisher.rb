class Cms::Publisher < ApplicationRecord
  include Sys::Model::Base

  STATE_OPTIONS = [['待機中','queued'],['実行中','performing']]

  belongs_to :publishable, polymorphic: true

  validate :validate_queue, on: :create

  before_save :set_priority

  private

  def validate_queue
    if self.class.where(state: 'queued', publishable_id: publishable_id, publishable_type: publishable_type)
           .where("extra_flag = ?", extra_flag.to_json)
           .exists?
      errors.add(:publishable_id, :taken)
    end
  end

  def set_priority
    self.priority = if publishable.is_a?(Cms::Node) && publishable.top_page?
                    10
                  elsif publishable.is_a?(GpCategory::Category)
                    20
                  else
                    30
                  end
  end

  class << self
    def register(site_id, items, extra_flag = {})
      items = Array(items)
      return if items.blank?
      pubs = items.map do |item|
        pub = self.new(site_id: site_id, publishable: item, state: 'queued', extra_flag: extra_flag)
        pub.run_callbacks(:save) { false }
        pub
      end
      self.import(pubs)

      Cms::PublisherJob.perform_later unless Cms::PublisherJob.queued?
    end
  end
end
