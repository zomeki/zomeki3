module Cms::Model::Site
  extend ActiveSupport::Concern
  include Cms::Model::Site::Scope

  class << self
    def sub_models
      return @@sub_models if defined? @@sub_models
      Rails.application.eager_load!
      @@sub_models = ApplicationRecord.descendants.sort_by(&:name)
                                      .select { |model| model.ancestors.include?(Cms::Model::Site) }
                                      .select { |model| sub_model_directly?(model) }
    end

    def sub_model_directly?(model)
      ((model.ancestors - [model]) & inheritable_models).size == 0
    end

    def inheritable_models
      [
        Cms::Content, Cms::ContentSetting, Cms::Piece, Cms::Node, Cms::SiteSetting, Cms::Publisher,
        GpCategory::CategoryType, GpCategory::Category
      ]
    end
  end
end
