class Cms::SiteScanService < ApplicationService
  def initialize(site)
    @site = site
  end

  def scan
    models = load_models
    models.each_with_object({}) do |model, hash|
      hash[model] = model.unscoped
                         .in_site(@site)
                         .order(model.primary_key)
                         .pluck(model.primary_key)
    end
  end

  private

  def load_models
    Rails.application.eager_load! unless Rails.env.production?
    klasses = ActiveRecord::Base.descendants.select { |klass| klass.respond_to?(:in_site) }
    klasses.select! { |klass| ((klass.ancestors - [klass]) & klasses).empty? }
    klasses.sort_by(&:name)
  end
end
