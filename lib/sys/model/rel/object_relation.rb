module Sys::Model::Rel::ObjectRelation
  def self.included(mod)
    mod.has_many :object_relations, class_name: 'Sys::ObjectRelation', dependent: :destroy, as: :source
    mod.has_many :related_objects, through: :object_relations, source: :related, source_type: mod.name

    mod.has_many :reverse_object_relations, class_name: 'Sys::ObjectRelation', dependent: :destroy, as: :related
    mod.has_many :relatee_objects, through: :reverse_object_relations, source: :source, source_type: mod.name
  end

  def object_related?
    object_relations.present?
  end

  def replace_page
    object_relations.where(relation_type: 'replace').first.try!(:related)
  end

  def replace_page?
    !!replace_page
  end

  def replaced_page
    reverse_object_relations.where(relation_type: 'replace').first.try!(:source)
  end

  def replaced_page?
    !!replaced_page
  end
end
