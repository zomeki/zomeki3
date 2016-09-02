class Cms::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  STATE_OPTIONS = [['待機中','queued'],['実行中','performing']]

  belongs_to :publishable, polymorphic: true

  validates :publishable_id, uniqueness: { scope: [:publishable_type, :state, :extra_flag] }

  class << self
    def register(site_id, items, extra_flag = {})
      items = Array(items)
      return if items.blank?

      pubs = items.map do |item|
        self.new(site_id: site_id, publishable: item, state: 'queued', extra_flag: extra_flag)
      end
      self.import(pubs)

      Cms::PublisherJob.perform_later unless Cms::PublisherJob.queued?
    end
  end
end
