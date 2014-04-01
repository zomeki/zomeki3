class Sys::Sequence < ActiveRecord::Base
  self.table_name = 'sys_sequences'

  scope :versioned, ->(v) { where(version: v) }

  validates :version, :uniqueness => {:scope => :name}

  def self.next(name, version)
    self.transaction do
      seq = self.lock.find_or_create_by(name: name, version: version)
      seq.increment!(:value)
      return seq
    end
  end
end
