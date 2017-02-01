class Sys::Sequence < ApplicationRecord
  self.table_name = 'sys_sequences'

  validates :version, uniqueness: { scope: [:site_id, :name] }

  def self.next(name, version, site_id)
    self.transaction do
      seq = self.lock.find_or_create_by(name: name, version: version, site_id: site_id)
      seq.increment!(:value)
      return seq
    end
  end
end
