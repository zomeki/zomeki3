module Cms::Model::Rel::Period
  extend ActiveSupport::Concern

  included do
    has_many :periods, -> { order(:started_on, :ended_on) },
                       class_name: 'Cms::Period', dependent: :destroy, as: :periodable
    accepts_nested_attributes_for :periods, allow_destroy: true, reject_if: :reject_periods_attributes?

    scope :scheduled_on, ->(date) {
      scheduled_between(date, date)
    }
    scope :scheduled_between, ->(start_date, end_date) {
      periods = Cms::Period.select(:periodable_id).where(periodable_type: self.name)
                           .dates_intersects(:started_on, :ended_on, start_date&.beginning_of_day, end_date&.end_of_day)
      where(id: periods)
    }
  end

  private

  def reject_periods_attributes?(attr)
    rejected = attr[:started_on].blank? && attr[:ended_on].blank?
    attr[:_destroy] = 1 if rejected
    attr[:id].blank? && rejected
  end
end
