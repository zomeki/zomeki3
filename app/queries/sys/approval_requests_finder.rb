class Sys::ApprovalRequestsFinder < ApplicationFinder
  def initialize(site, user)
    @site = site
    @user = user
  end

  def find
    items = load_recognition_items(Cms::Node::Page)

    models = load_approvable_models
    models.each do |model|
      items += load_approval_items(model)
    end

    items
  end

  private

  def load_recognition_items(model)
    model.where(site: @site)
         .recognition_requested_by(@user)
         .order(:id)
  end

  def load_approvable_models
    Approval::ApprovalRequest.order(:approvable_type)
                             .group(:approvable_type)
                             .pluck(:approvable_type)
                             .map(&:safe_constantize).compact
  end

  def load_approval_items(model)
    model.distinct.in_site(@site)
         .approval_requested_by(@user)
         .order(:content_id, :id)
         .preload(:content, :creator => [:user, :group])
  end
end
