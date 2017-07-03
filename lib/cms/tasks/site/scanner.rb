class Cms::Tasks::Site::Scanner
  def initialize(site)
    @site = site
    @models = Cms::Model::Site.sub_models
  end

  def scan_ids
    @models.each_with_object(HashWithIndifferentAccess.new) do |model, hash|
      hash[model.table_name] = model.in_site(@site)
                                    .order(model.primary_key)
                                    .pluck(model.primary_key)
    end
  end
end
