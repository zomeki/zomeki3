class Sys::TransferableFilesScript < Cms::Script::Base
  include Sys::Lib::File::Transfer

  def push
    transfer_files(:logging => true)
  end
end
