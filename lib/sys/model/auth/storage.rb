module Sys::Model::Auth::Storage
  def readable?
    return false unless site
    return true if Core.user.root? || (Core.user.has_auth?(:manager) && Core.user.sites.include?(site))
    Core.user.has_auth?(:designer) && Core.user.sites.include?(site) && path =~ %r|^#{site.public_path}|
  end

  def creatable?
    return false unless readable?
    Core.user.has_auth?(:manager) || (Core.user.has_auth?(:designer) && (related_node.blank? || related_node.content_id.blank?))
  end

  def editable?
    return false unless readable?
    Core.user.has_auth?(:manager) || (Core.user.has_auth?(:designer) && !system_dir? && related_node.blank?)
  end

  def deletable?
    editable?
  end
end
