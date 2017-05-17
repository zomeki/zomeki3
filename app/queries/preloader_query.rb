class PreloaderQuery < ApplicationQuery
  def initialize(relation)
    @relation = relation
  end

  def preload(*assoc_methods)
    assocs = merge_assocs(assoc_methods)
    if @relation.is_a?(ActiveRecord::Relation) || @relation.is_a?(ActiveRecord::Associations::CollectionProxy)
      @relation.preload(assocs)
    else
      ActiveRecord::Associations::Preloader.new.preload(@relation, assocs)
      @relation
    end
  end

  private

  def merge_assocs(assoc_methods)
    assocs = assoc_methods.map do |method|
      if self.class.respond_to?(method)
        ret = self.class.public_send(method)
        ret if ret.is_a?(Hash)
      else
        { method => nil }
      end
    end
    assocs.compact!
    assocs.each_with_object({}) do |assoc, hash|
      hash.deep_merge!(assoc) if assoc
    end
  end
end
