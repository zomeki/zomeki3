module Cms::Model::Auth::Concept::Creator
  extend ActiveSupport::Concern

  def creatable?
    Core.user.has_priv?(:create, item: concept)
  end
  
  def readable?
    Core.user.has_priv?(:read, item: concept)
  end
  
  def editable?
    Core.user.has_priv?(:update, item: concept)
  end

  def deletable?
    Core.user.has_priv?(:delete, item: concept)
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
