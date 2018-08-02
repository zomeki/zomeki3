module Cms::Model::Rel::Period
  extend ActiveSupport::Concern

  included do
    has_many :periods, -> { order(:started_on, :ended_on) },
                       class_name: 'Cms::Period', dependent: :destroy, as: :periodable
    accepts_nested_attributes_for :periods, allow_destroy: true, reject_if: :all_blank

    scope :scheduled_on, ->(date) {
      scheduled_between(date, date)
    }
    scope :scheduled_between, ->(start_date, end_date) {
      periods = Cms::Period.select(:periodable_id).where(periodable_type: self.to_s)
                           .dates_intersects(:started_on, :ended_on, start_date&.beginning_of_day, end_date&.end_of_day)
      where(id: periods)
    }
  end
end
