module Sys::Model::Auth::Manager
  extend ActiveSupport::Concern

  def creatable?
    Core.user.has_auth?(:manager)
  end

  def readable?
    Core.user.has_auth?(:manager)
  end

  def editable?
    Core.user.has_auth?(:manager)
  end

  def deletable?
    Core.user.has_auth?(:manager)
  end

  class_methods do
    def readable
      Core.user.has_auth?(:manager) ? all : none
    end

    def editable
      Core.user.has_auth?(:manager) ? all : none
    end
  end
end
