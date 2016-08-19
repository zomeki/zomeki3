class GpCategory::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    GpCategory::Content::CategoryType
  end
end
