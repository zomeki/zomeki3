class Reception::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    Reception::Content::Course
  end
end
