class Sys::Reorg::Schedule < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Site
  include Cms::Model::Auth::Site

  enum_ish :state, [:reserved, :performed]

  validates :site_id, uniqueness: true
  validates :reserved_at, presence: true
  validate :validate_reserved_at

  before_update :destroy_delayed_jobs
  before_destroy :destroy_delayed_jobs

  private

  def validate_reserved_at
    if reserved_at && reserved_at < Time.now
      errors.add(:reserved_at, :not_after_current_datetime)
    end
  end

  def destroy_delayed_jobs
    Delayed::JobExtension.with_global_id(to_global_id).destroy_all
  end
end
