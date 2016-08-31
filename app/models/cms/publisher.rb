class Cms::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  STATE_OPTIONS = [['待機中','queued'],['実行中','performing']]

  belongs_to :publishable, polymorphic: true

  validates :publishable_id, uniqueness: { scope: [:publishable_type, :state] }

  class << self
    def register(items)
      items = Array(items)
      return if items.blank?

      pubs = items.map { |item| self.new(publishable: item, state: 'queued') }
      self.import(pubs)

      Cms::PublisherJob.perform_later unless Cms::PublisherJob.queued?
    end
  end
end
