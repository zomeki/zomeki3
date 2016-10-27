module Sys::Model::Base::Page
  def states
    [['公開','public'],['非公開','closed']]
  end

  def public?
    return state == 'public' && !published_at.blank?
  end
end
