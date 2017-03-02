module Cms::Model::Auth::Concept
  extend ActiveSupport::Concern

  def creatable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:create, item: concept, site_id: read_attribute(:site_id))
  end
  
  def readable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:read, item: concept, site_id: read_attribute(:site_id))
  end
  
  def editable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:update, item: concept, site_id: read_attribute(:site_id))
  end

  def deletable?
    return false unless Core.user.has_auth?(:designer)
    return Core.user.has_priv?(:delete, item: concept, site_id: read_attribute(:site_id))
  end

  class_methods do
    def readable
      rel = Core.site ? where(site_id: Core.site.id)
                      : where(site_id: nil)
      if Core.concept
        if Core.user.has_priv?(:read, item: Core.concept)
          rel.where(concept_id: Core.concept.id)
        else
          rel.none
        end
      else
        rel.where(concept_id: nil)
      end
    end
  end
end
