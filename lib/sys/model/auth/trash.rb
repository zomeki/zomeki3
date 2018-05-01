module Sys::Model::Auth::Trash
  extend ActiveSupport::Concern

  def trashable?
    deletable?
  end

  def untrashable?
    deletable? && state_trashed?
  end
end
