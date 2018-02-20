class Cms::Tasks::Site::Scanner
  def initialize(site)
    @site = site
    @models = self.class.in_site_models
  end

  def scan_ids
    @models.each_with_object(HashWithIndifferentAccess.new) do |model, hash|
      hash[model.table_name] = model.in_site(@site)
                                    .order(model.primary_key)
                                    .pluck(model.primary_key)
    end
  end

  class << self
    def in_site_models(include_subclass: false)
      Rails.application.eager_load!
      klasses = ActiveRecord::Base.descendants.select { |klass| klass.respond_to?(:in_site) }
      klasses.select! { |klass| ((klass.ancestors - [klass]) & klasses).empty? } unless include_subclass
      klasses.sort_by(&:name)
    end
  end
end
