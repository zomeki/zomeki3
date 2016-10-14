class Sys::Task < ApplicationRecord
  include Sys::Model::Base

  belongs_to :processable, polymorphic: true

  def publish_task?
    name == 'publish'
  end

  def close_task?
    name == 'close'
  end
end
