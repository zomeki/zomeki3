module Cms::Model::Site::Scope
  extend ActiveSupport::Concern

  class_methods do
    def define_site_scope(assoc)
      ref = reflect_on_association(assoc)
      raise StandardError.new("can't find association #{assoc} from #{caller[0]}") unless ref

      if ref.polymorphic?
        define_polymorphic_site_scope(ref)
      else
        case ref.class.to_s
        when 'ActiveRecord::Reflection::HasManyReflection', 'ActiveRecord::Reflection::HasOneReflection'
          define_has_many_or_has_one_site_scope(ref)
        when 'ActiveRecord::Reflection::BelongsToReflection'
          define_belongs_to_site_scope(ref)
        else
          raise StandardError.new("unexpected reflection #{ref} from #{caller[0]}")
        end
      end
    end

    private

    def define_has_many_or_has_one_site_scope(ref)
      class_eval do
        scope :in_site, ->(site) { where(primary_key => ref.klass.select(ref.foreign_key).in_site(site)) }
      end
    end

    def define_belongs_to_site_scope(ref)
      class_eval do
        scope :in_site, ->(site) { where(ref.foreign_key => ref.klass.in_site(site)) }
      end
    end

    def define_polymorphic_site_scope(ref)
      p_type = "#{ref.name}_type"
      p_id = "#{ref.name}_id"
      class_eval do
        scope :in_site, ->(site) {
          model_names = unscoped.group(p_type).pluck(p_type).compact
          rels = model_names.map { |model_name|
                   model = model_name.safe_constantize
                   where(p_type => model_name, p_id => model.in_site(site)) if model && model.respond_to?(:in_site)
                 }.compact
          union(rels)
        }
      end
    end
  end
end
