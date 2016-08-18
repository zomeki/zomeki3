module Sys::Model::Auth::Designer
  extend ActiveSupport::Concern

  included do
    scope :readable, -> { Core.user.has_auth?(:designer) ? all : none }
    scope :editable, -> { Core.user.has_auth?(:designer) ? all : none }
  end

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
end
