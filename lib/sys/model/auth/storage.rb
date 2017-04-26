module Sys::Model::Auth::Storage
  def readable?
    return false unless site
    return false unless Core.user.has_auth?(:designer)
    Core.user.root? || (Core.user.sites.include?(site) && path =~ %r|^#{site.public_path}|)
  end

  def creatable?
    readable?
  end

  def editable?
    readable?
  end

  def deletable?
    readable?
  end
end
