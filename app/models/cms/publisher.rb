class Cms::Publisher < ApplicationRecord
  include Sys::Model::Base

  STATE_OPTIONS = [['待機中','queued'],['実行中','performing']]

  belongs_to :publishable, polymorphic: true

  scope :queued_items, -> {
    where([
      arel_table[:state].eq('queued'),
      [arel_table[:state].eq('performing'), arel_table[:updated_at].lt(Time.now - 3.hours)].reduce(:and)
    ].reduce(:or))
  }

  class << self
    def register(site_id, items, extra_flag = {})
      items = Array(items)
      return if items.blank?

      queued_map = make_queued_map(site_id)
      items = items.select do |item|
        gid = "#{item.class}/#{item.id}"
        !queued_map.key?(gid) || queued_map[gid].all? { |queued| queued.extra_flag != extra_flag.stringify_keys }
      end

      pubs = items.map do |item|
               pub = self.new(site_id: site_id, publishable: item, state: 'queued', extra_flag: extra_flag)
               pub.priority = determine_priority(item)
               pub
             end
      self.import(pubs)

      Cms::PublisherJob.perform_later unless Cms::PublisherJob.queued?
    end

    private

    def determine_priority(item)
      if item.is_a?(Cms::Node) && item.top_page?
        10
      elsif item.is_a?(GpCategory::Category)
        20
      else
        30
      end
    end

    def make_queued_map(site_id)
      items = self.where(site_id: site_id, state: 'queued')
      items.group_by { |item| "#{item.publishable_type}/#{item.publishable_id}" }
    end
  end
end
