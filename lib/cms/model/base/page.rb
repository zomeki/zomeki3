module Cms::Model::Base::Page
  def public?
    state == 'public'
  end
end
