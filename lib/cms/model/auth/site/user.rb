module Cms::Model::Auth::Site::User
  def creatable?
    readable?
  end
  
  def readable?
    return false unless Core.user.has_auth?(:manager)
    Core.user.root? || (user && (user.sites & Core.user.sites).present?)
  end
  
  def editable?
    readable?
  end

  def deletable?
    readable?
  end
end
