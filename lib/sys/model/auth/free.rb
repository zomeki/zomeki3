module Sys::Model::Auth::Free
  extend ActiveSupport::Concern

  def creatable?
    true
  end

  def readable?
    true
  end

  def editable?
    true
  end

  def deletable?
    true
  end

  class_methods do
    def readable
      all
    end

    def editable
      all
    end
  end
end
