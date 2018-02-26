class Survey::Slave::Answer < ApplicationRecordSlave
  include Sys::Model::Slave

  has_one :attachment, dependent: :destroy
end
