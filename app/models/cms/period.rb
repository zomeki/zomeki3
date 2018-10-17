class Cms::Period < ApplicationRecord
  include Sys::Model::Base

  belongs_to :periodable, polymorphic: true

  validate :validate_dates_range

  def intersect?(start_date, end_date)
    (start_date.blank? || start_date <= ended_on) &&
      (end_date.blank? || end_date >= started_on)
  end

  private

  def validate_dates_range
    return if self.started_on.blank? && self.ended_on.blank?
    self.started_on = self.ended_on if self.started_on.blank?
    self.ended_on = self.started_on if self.ended_on.blank?
    errors.add(:ended_on, "が#{self.class.human_attribute_name :started_on}を過ぎています。") if self.ended_on < self.started_on
  end
end
