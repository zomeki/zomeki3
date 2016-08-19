class Approval::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    Approval::Content::ApprovalFlow
  end
end
