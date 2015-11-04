module Sys::Model::Preload
  extend ActiveSupport::Concern

  included do
    scope :preload_assocs, ->(*assoc_methods) {
      preload(merge_assocs(assoc_methods))
    }
  end

  def preload_assocs(*assoc_methods)
    assocs = self.class.merge_assocs(assoc_methods)
    ActiveRecord::Associations::Preloader.new.preload(self, assocs)
    self
  end

  module ClassMethods
    def preload_assocs_for(objects, *assoc_methods)
      assocs = merge_assocs(assoc_methods)
      ActiveRecord::Associations::Preloader.new.preload(objects, assocs)
      objects
    end

    def merge_assocs(assoc_methods)
      assocs = assoc_methods.map do |method|
        if respond_to?(method)
          ret = send(method)
          ret if ret.is_a?(Hash)
        elsif reflect_on_association(method)
          {method => nil}
        end
      end
      assocs.compact!
      assocs.each_with_object({}) do |assoc, hash|
        hash.deep_merge!(assoc) if assoc
      end
    end
  end
end
