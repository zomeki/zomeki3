module Sys::Model::Auth::Manager
  extend ActiveSupport::Concern

  included do
    scope :readable, -> { Core.user.has_auth?(:manager) ? all : none }
    scope :editable, -> { Core.user.has_auth?(:manager) ? all : none }
  end

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
end
