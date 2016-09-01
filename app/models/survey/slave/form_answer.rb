class Survey::Slave::FormAnswer < ApplicationRecordSlave
  include Sys::Model::Slave
  has_many :answers, dependent: :destroy
end
