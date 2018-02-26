class Survey::Slave::Attachment < ApplicationRecordSlave
  include Sys::Model::Slave

  belongs_to :answer
end
