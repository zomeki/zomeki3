module Cms::Model::Auth::Site::Role
  def creatable?
    readable?
  end
  
  def readable?
    return false unless Core.user.has_auth?(:manager)
    Core.user.root? || (role_name && role_name.site && Core.user.sites.include?(role_name.site))
  end
  
  def editable?
    readable?
  end

  def deletable?
    readable?
  end
end
