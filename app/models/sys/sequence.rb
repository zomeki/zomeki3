class Sys::Sequence < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Site

  validates :version, uniqueness: { scope: [:site_id, :name] }

  def self.next(name, version, site_id)
    try = 0

    begin
      try += 1
      self.transaction do
        seq = self.find_or_create_by!(name: name, version: version, site_id: site_id)
        seq.lock!
        seq.increment!(:value)
        return seq
      end
    rescue ActiveRecord::RecordInvalid => e
      if try < 5
        retry
      else
        raise e
      end
    end
  end
end
