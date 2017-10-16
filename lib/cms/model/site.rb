module Cms::Model::Site
  extend ActiveSupport::Concern
  include Cms::Model::Site::Scope

  class << self
    def sub_models(include_subclass: false)
      return @@sub_models if defined? @@sub_models
      Rails.application.eager_load!
      klasses = ActiveRecord::Base.descendants.select { |klass| klass.include?(self) }
      klasses.select! { |klass| ((klass.ancestors - [klass]) & klasses).empty? } unless include_subclass
      @@sub_models = klasses.sort_by(&:name)
    end
  end
end
