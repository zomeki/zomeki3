module Sys::Model::Auth::Designer
  extend ActiveSupport::Concern

  def creatable?
    Core.user.has_auth?(:designer)
  end

  def readable?
    Core.user.has_auth?(:designer)
  end

  def editable?
    Core.user.has_auth?(:designer)
  end

  def deletable?
    Core.user.has_auth?(:designer)
  end

  class_methods do
    def readable
      Core.user.has_auth?(:designer) ? all : none
    end

    def editable
      Core.user.has_auth?(:designer) ? all : none
    end
  end
end
