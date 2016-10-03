module Sys::Model::Rel::ObjectRelation
  extend ActiveSupport::Concern

  included do
    has_many :object_relations, class_name: 'Sys::ObjectRelation', dependent: :destroy, as: :source
    has_many :related_objects, through: :object_relations, source: :related, source_type: name
    has_many :reverse_object_relations, class_name: 'Sys::ObjectRelation', dependent: :destroy, as: :related
    has_many :relatee_objects, through: :reverse_object_relations, source: :source, source_type: name

    has_many :object_relations_for_replace, -> { where(relation_type: 'replace') }, class_name: 'Sys::ObjectRelation', dependent: :destroy, as: :source
    has_many :related_objects_for_replace, through: :object_relations_for_replace, source: :related, source_type: name
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
